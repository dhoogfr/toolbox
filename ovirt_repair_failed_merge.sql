-- noinspection SqlNoDataSourceInspectionForFile
-- Repair function for failed Live Merge.

-- This is to be run ONLY if the image removal failed, i.e. after a merge fails
-- during the DESTROY_IMAGE or DESTROY_IMAGE_CHECK stages.  It tries the verify this,
-- but due to a bug, some cases look just like a merge had not even been attempted.
-- Running the script in this scenario WILL CORRUPT YOUR DATA.

-- As always, back up your database first!

-- As for how this works, it is similar to RemoveSnapshotSingleDiskLiveCommand.java's
-- syncDbRecords() method; this comment is lifted straight from there:

-- For backwards merge, the prior base image now has the data associated with the newer
-- snapshot we want to keep.  Re-associate this older image with the newer snapshot.
-- The base snapshot is deleted if everything went well.

CREATE OR REPLACE FUNCTION ovirt_repair_failed_merge(
    v_vm_name VARCHAR,
    v_snapshot_name VARCHAR,
    v_disk_alias VARCHAR,
    v_removed_image_uuid VARCHAR)
RETURNS VARCHAR
AS $PROCEDURE$

DECLARE 
    v_bad_img UUID;       -- topImage, the newer image that's been merged (the "bad" one)
    v_good_img UUID;      -- baseImage, the older image with data to keep (the "good" one)
    v_verify RECORD;      -- verification result for choosing what to do
    v_swap BOOLEAN;       -- swapping images is needed
    v_tmp images%ROWTYPE; -- temp var used for swapping values
    v_snapstr VARCHAR;    -- snapshot description used in notice/exception messages
    v_has_volume_classification BOOLEAN;
BEGIN
    SET CLIENT_MIN_MESSAGES = 'notice';

    -- Make this easier to keep straight; it's shorter too...
    v_bad_img := v_removed_image_uuid::UUID;

    v_snapstr := 'snapshot for VM "' || v_vm_name || '" with description "' || v_snapshot_name || '", disk "' || v_disk_alias || '"';

    -- There are 3 cases to check for:
    --  1. The given snapshot has the given image, with no parent and illegal status
    --     => the removal call failed and the vales were swapped, just delete the entities
    --  2. The given snapshot's parent has the image, with a parent and OK status
    --     => no recovery prep ran, switch the values and delete the entities
    --  3. Anything besides the above
    --     => something isn't right, better abort

    SELECT images.* INTO v_verify
    FROM images
    JOIN base_disks ON (images.image_group_id = base_disks.disk_id)
    JOIN snapshots ON (images.vm_snapshot_id = snapshots.snapshot_id)
    JOIN vm_static ON (snapshots.vm_id = vm_static.vm_guid)
    WHERE vm_static.vm_name = v_vm_name
        AND snapshots.description = v_snapshot_name
        AND base_disks.disk_alias = v_disk_alias;

    IF (v_verify IS NULL) THEN
        RAISE EXCEPTION 'No % found ', v_snapstr;
    ELSIF (v_verify.image_guid = v_bad_img
            AND v_verify.imagestatus = 4
            AND v_verify.parentid = '00000000-0000-0000-0000-000000000000'::UUID) THEN
        RAISE NOTICE 'Image values are already correct; proceeding with removal of image "%" of %s',
                v_bad_img, v_snapstr;
        v_swap := FALSE;
    ELSE
        RAISE WARNING 'Specified image with imagestatus=4 (ILLEGAL) and no parent (parentid = 00000000-0000-0000-0000-000000000000) not found; searching for child...';

        -- Used below if swap is true
        v_good_img := v_verify.image_guid;

        SELECT images.* INTO v_verify
        FROM images
        WHERE parentid = v_good_img;

        IF (v_verify IS NULL) THEN
            RAISE EXCEPTION 'No child images found for %', v_snapstr;
        ELSIF (v_verify.image_guid = v_bad_img AND v_verify.imagestatus = 1) THEN
            RAISE NOTICE 'Proceeding with repair; correcting image values and removing image "%" of "%"',
                    v_bad_img, v_snapstr;
            v_swap := TRUE;
        ELSE
            RAISE EXCEPTION 'Child image of % has wrong id and/or status; expected "%" / "%" but got "%" / "%"',
                    v_snapstr, v_bad_img, 1, v_verify.image_guid, v_verify.imagestatus;
        END IF;
    END IF;

    IF (v_swap IS TRUE) THEN
        -- update any children of the bad image to point to the good one
        UPDATE images SET parentid = v_good_img WHERE parentid = v_bad_img;

        -- Copy needed values from the bad image to the good one and set the status to OK.
        -- The bad image's snapshot id is adjusted in case there are cascading deletions.
        SELECT * INTO v_tmp FROM images WHERE image_guid = v_bad_img;

        UPDATE images
        SET vm_snapshot_id = (SELECT vm_snapshot_id FROM images WHERE image_guid = v_good_img)
        WHERE image_guid = v_bad_img;

        UPDATE images
        SET vm_snapshot_id = v_tmp.vm_snapshot_id,
            size = v_tmp.size,
            active = v_tmp.active,
            imagestatus = 1
        WHERE image_guid = v_good_img;

        SELECT TRUE INTO v_has_volume_classification
        FROM information_schema.columns
        WHERE table_name = 'images'
            AND column_name = 'volume_classification';

        IF (v_has_volume_classification IS NOT NULL) THEN
            UPDATE images
            SET volume_classification = v_tmp.volume_classification
            WHERE image_guid = v_good_img;
        END IF;
    END IF;

    -- everything's now swapped; remove the bad image and (optionally) the associated snapshot
    DELETE FROM snapshots
    WHERE snapshot_id =
            (SELECT vm_snapshot_id FROM images WHERE image_guid = v_bad_img)
        AND snapshot_id NOT IN
            (SELECT vm_snapshot_id FROM images WHERE image_guid != v_bad_img AND vm_snapshot_id IS NOT NULL);
    IF FOUND THEN
        RAISE NOTICE 'Removed snapshot';
    END IF;
    DELETE FROM images WHERE image_guid = v_bad_img;
    RAISE NOTICE 'Removed image %', v_bad_img;

    RESET CLIENT_MIN_MESSAGES;

    RAISE NOTICE 'Success';
    RETURN 'Success';

END;$PROCEDURE$
LANGUAGE plpgsql;
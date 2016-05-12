
alter TABLE ACCOUNTS move
 tablespace ARTIS_OBJ;

alter INDEX ACC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_CHANGES_I move
 tablespace ARTIS_OBJ;

alter INDEX ACI_BATCH_NR_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ACI_LOAD_DATE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ACI_U rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_DED move
 tablespace ARTIS_OBJ;

alter INDEX ADD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_DED_OLD move
 tablespace ARTIS_OBJ;

alter TABLE ADDRESS_ENHANCE_STATUSES move
 tablespace ARTIS_OBJ;

alter INDEX AES_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_ENH_RUN_LOG move
 tablespace ARTIS_OBJ;

alter INDEX AEL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_KEYWORDS move
 tablespace ARTIS_OBJ;

alter INDEX AKW_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ADDRESS_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX ATY_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ARCHIVE_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX ARD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ARCHIVE_LOG move
 tablespace ARTIS_OBJ;

alter INDEX ARL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ARTIS_ARTICLES move
 tablespace ARTIS_OBJ;

alter INDEX AAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ARTIS_ARTICLE_SALES move
 tablespace ARTIS_OBJ;

alter INDEX AAS_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX AAS_TICKET_NO_I rebuild
 tablespace ARTIS_NDX;

alter TABLE ARTIS_PROMOTIONS move
 tablespace ARTIS_OBJ;

alter INDEX APM_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX APM_TICKET_NO_I rebuild
 tablespace ARTIS_NDX;

alter TABLE ARTIS_VISITS move
 tablespace ARTIS_OBJ;

alter INDEX AVI_CARD_NO_I rebuild
 tablespace ARTIS_NDX;

alter INDEX AVI_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ATTRIBUTE_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX ATT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE BAD_WORDS move
 tablespace ARTIS_OBJ;

alter INDEX BDW_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE BRANDS move
 tablespace ARTIS_OBJ;

alter INDEX BRA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE BRIDGE_REF_CODES move
 tablespace ARTIS_OBJ;

alter INDEX BRC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CAMPAIGNS move
 tablespace ARTIS_OBJ;

alter INDEX CAM_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX CAM_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE CELL_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX CET_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CHANNELS move
 tablespace ARTIS_OBJ;

alter INDEX CHA_CHT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CHA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CHANNEL_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX CHT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CHA_COSTS move
 tablespace ARTIS_OBJ;

alter INDEX CHX_COC_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CHX_COT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CHX_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMMUNICATIONS move
 tablespace ARTIS_OBJ;

alter INDEX COM_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX COM_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMMUNICATION_CHANNELS move
 tablespace ARTIS_OBJ;

alter INDEX COC_CVE_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX COC_UK rebuild
 tablespace ARTIS_NDX;

alter INDEX COC_DC_CODE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX COC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMMUNICATION_VEHICLES move
 tablespace ARTIS_OBJ;

alter INDEX CVE_COM_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CVE_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX CVE_VET_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CVE_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANIES move
 tablespace ARTIS_OBJ;

alter INDEX CNY_EXT_REF_I rebuild
 tablespace ARTIS_NDX;

alter INDEX CNY_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANY_CST_RELATIONS move
 tablespace ARTIS_OBJ;

alter INDEX CCR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANY_FLEX_FIELDS move
 tablespace ARTIS_OBJ;

alter INDEX CFF_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANY_IDS_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX CIT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANY_STRUCTURE move
 tablespace ARTIS_OBJ;

alter INDEX CST_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COMPANY_VARIATIONS move
 tablespace ARTIS_OBJ;

alter INDEX CMV_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COM_COSTS move
 tablespace ARTIS_OBJ;

alter INDEX COX_COM_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX COX_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX COX_COT_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE CORRECTED_LANGUAGES move
 tablespace ARTIS_OBJ;

alter INDEX CRL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COST_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX COT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COUNT_COMMON_CONDITIONS move
 tablespace ARTIS_OBJ;

alter INDEX CCD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE COUNT_TABLE_CONDITIONS move
 tablespace ARTIS_OBJ;

alter INDEX CTC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CS_EXPORT_LOGS move
 tablespace ARTIS_OBJ;

alter INDEX CEL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE CUMULATION_PER_CARD move
 tablespace ARTIS_OBJ;

alter INDEX CPC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DATA_EXTRACTS move
 tablespace ARTIS_OBJ;

alter INDEX DEX_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DATA_EXTRACT_COLUMNS move
 tablespace ARTIS_OBJ;

alter INDEX DEC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DATA_EXTRACT_CONDITIONS move
 tablespace ARTIS_OBJ;

alter INDEX DECO_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DEBUGTAB move
 tablespace ARTIS_OBJ;

alter INDEX SYS_C0018682 rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_ANALYSIS move
 tablespace ARTIS_OBJ;

alter INDEX ANAL_DRL_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ANAL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_COMPARE_FIELDS move
 tablespace ARTIS_OBJ;

alter INDEX COMP_FLD_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX COMP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_COMPARE_PROCESSES move
 tablespace ARTIS_OBJ;

alter INDEX CPRO_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX CPRO_PROC_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_COPY_CHILD_TABLES move
 tablespace ARTIS_OBJ;

alter INDEX CCT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_DEDUPLICATION_MASTERS move
 tablespace ARTIS_OBJ;

alter INDEX FLD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_DEDUPLICATION_RUN_LOG move
 tablespace ARTIS_OBJ;

alter INDEX DRL_FLD_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX DRL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_INDIVIDUAL move
 tablespace ARTIS_OBJ;

alter INDEX MATCHKEY_1_NDX rebuild
 tablespace ARTIS_NDX;

alter INDEX URN_NDX rebuild
 tablespace ARTIS_NDX;

alter INDEX PARENT_URN_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_MATCHKEY_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX MDET_FLD_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX MDET_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_MAYBE_DATA move
 tablespace ARTIS_OBJ;

alter TABLE DED_MAYBE_POINTS move
 tablespace ARTIS_OBJ;

alter INDEX REC_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX REC_UK1 rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_PROCESSES move
 tablespace ARTIS_OBJ;

alter INDEX PROC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_RECORD_POINTS move
 tablespace ARTIS_OBJ;

alter INDEX REC_CHILD_URN_UI rebuild
 tablespace ARTIS_NDX;

alter INDEX REC_UID_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_SOURCE_KEY_MAPPINGS move
 tablespace ARTIS_OBJ;

alter INDEX SKM_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_T_ANALYSIS_SUMMARY move
 tablespace ARTIS_OBJ;

alter TABLE DED_T_IND_STRUCTURE move
 tablespace ARTIS_OBJ;

alter INDEX STC_PARENT_URN_I rebuild
 tablespace ARTIS_NDX;

alter TABLE DED_T_MATCHKEYS_VALUE move
 tablespace ARTIS_OBJ;

alter TABLE DED_T_MATCHKEY_ROWS move
 tablespace ARTIS_OBJ;

alter TABLE DED_T_MKEY_SQL_STMT move
 tablespace ARTIS_OBJ;

alter TABLE DED_T_MKEY_STMT move
 tablespace ARTIS_OBJ;

alter TABLE DED_T_URN move
 tablespace ARTIS_OBJ;

alter TABLE DEPARTMENTS move
 tablespace ARTIS_OBJ;

alter INDEX DEP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DEPARTMENT_VARIATIONS move
 tablespace ARTIS_OBJ;

alter INDEX DPV_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DEX_TEMPLATES move
 tablespace ARTIS_OBJ;

alter INDEX DEXT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DEX_TEMPLATE_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX DTD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DFM_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX DFD_U rebuild
 tablespace ARTIS_NDX;

alter TABLE DFM_HEADER move
 tablespace ARTIS_OBJ;

alter INDEX DFH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DFM_MEMBERS move
 tablespace ARTIS_OBJ;

alter INDEX DMM_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DFM_RESULTS move
 tablespace ARTIS_OBJ;

alter INDEX DFR_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX DFR_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE DM_200310 move
 tablespace ARTIS_OBJ;

alter INDEX DM_200310_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE DRINK_GIFT_VOLUME move
 tablespace ARTIS_OBJ;

alter TABLE EDUCARD_TRANS move
 tablespace ARTIS_OBJ;

alter INDEX EDT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE EMAIL_ERROR_LOG move
 tablespace ARTIS_OBJ;

alter INDEX EEL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE EMAIL_RESPONSES move
 tablespace ARTIS_OBJ;

alter INDEX EMR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ENHANCEMENTS move
 tablespace ARTIS_OBJ;

alter INDEX ENH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE ENHANCEMENTS_LOG move
 tablespace ARTIS_OBJ;

alter INDEX ENL_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX ENL_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE ENHANCEMENTS_RESULTS move
 tablespace ARTIS_OBJ;

alter INDEX ERE_ENC_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ERE_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX ERE_ENL_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE ENHANCEMENTS_RUN move
 tablespace ARTIS_OBJ;

alter INDEX ENR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FAMILY_CARD move
 tablespace ARTIS_OBJ;

alter INDEX FAMILY_CARD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FS_CELL_74 move
 tablespace ARTIS_OBJ;

alter INDEX FS_CELL_74_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FS_CELL_75 move
 tablespace ARTIS_OBJ;

alter INDEX FS_CELL_75_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FS_CELL_78 move
 tablespace ARTIS_OBJ;

alter INDEX FS_CELL_78_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FS_CELL_79 move
 tablespace ARTIS_OBJ;

alter INDEX FS_CELL_79_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE FULFILMENT_ITEMS move
 tablespace ARTIS_OBJ;

alter INDEX FUI_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE GIFT_HABIT_CODES move
 tablespace ARTIS_OBJ;

alter INDEX GHC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE GRADES move
 tablespace ARTIS_OBJ;

alter TABLE IMP_ARTIS_10 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_10_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_100 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_100_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_101 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_101_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_102 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_102_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_103 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_103_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_104 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_104_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_105 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_105_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_106 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_106_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_107 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_107_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_108 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_108_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_109 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_109_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_11 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_11_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_110 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_110_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_111 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_111_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_112 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_112_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_113 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_113_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_114 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_114_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_115 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_115_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_116 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_116_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_12 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_12_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_13 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_13_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_14 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_14_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_15 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_15_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_16 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_16_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_18 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_18_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_19 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_19_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_20 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_20_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_21 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_21_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_22 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_22_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_23 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_23_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_24 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_24_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_25 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_25_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_26 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_26_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_27 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_27_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_28 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_28_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_29 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_29_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_3 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_3_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_30 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_30_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_31 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_31_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_32 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_32_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_33 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_33_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_34 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_34_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_35 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_36 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_37 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_38 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_39 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_4 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_4_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_40 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_41 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_41_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_42 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_42_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_43 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_43_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_44 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_44_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_45 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_45_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_46 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_46_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_47 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_47_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_48 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_48_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_49 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_49_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_5 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_5_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_50 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_50_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_51 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_52 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_52_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_53 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_53_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_54 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_54_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_55 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_56 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_57 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_57_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_58 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_58_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_59 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_6 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_60 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_60_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_61 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_61_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_62 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_62_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_63 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_63_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_64 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_64_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_65 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_65_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_66 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_66_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_67 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_67_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_68 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_68_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_69 move
 tablespace ARTIS_IMP;

alter TABLE IMP_ARTIS_7 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_7_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IMP_ARTIS_7_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_70 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_70_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_71 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_71_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_72 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_72_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_73 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_73_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_74 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_74_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_75 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_75_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_76 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_76_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_77 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_77_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_78 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_78_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_79 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_79_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_8 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_8_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_80 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_80_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_81 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_81_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_82 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_82_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_83 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_83_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_84 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_84_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_85 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_85_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_86 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_86_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_87 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_87_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_88 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_88_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_89 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_89_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_9 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_9_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_90 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_90_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_91 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_91_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_92 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_92_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_93 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_93_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_94 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_94_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_95 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_95_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_96 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_96_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_97 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_97_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_98 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_98_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE IMP_ARTIS_99 move
 tablespace ARTIS_IMP;

alter INDEX IMP_ARTIS_99_NDX rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUALS move
 tablespace ARTIS_OBJ;

alter INDEX IND_ACC_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IND_PARENT_URN_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IND_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX IND_LBR_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IND_EXTERNAL_REF_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IND_CUSTOMER_ID_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUALS_JN move
 tablespace ARTIS_OBJ;

alter TABLE INDIVIDUALS_ORG_ADDR move
 tablespace ARTIS_OBJ;

alter INDEX IOA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_ADDR_ENH_HIS move
 tablespace ARTIS_OBJ;

alter INDEX IEH_IND_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_ANSWERS move
 tablespace ARTIS_OBJ;

alter INDEX INA_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX INA_QUA_ANSWER_UID_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_ATTRIBUTES move
 tablespace ARTIS_OBJ;

alter INDEX IAT_ATT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IAT_INR_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_CARS move
 tablespace ARTIS_OBJ;

alter INDEX INC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_FAMILY move
 tablespace ARTIS_OBJ;

alter INDEX INF_INF_UID_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INF_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX INF_REL_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INF_UK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_FLEX_FIELDS move
 tablespace ARTIS_OBJ;

alter INDEX IFF_FIELD10_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IFF_ID_FAM rebuild
 tablespace ARTIS_NDX;

alter INDEX IFF_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_OTHER_CARS move
 tablespace ARTIS_OBJ;

alter INDEX INO_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_PREFERENCES move
 tablespace ARTIS_OBJ;

alter INDEX PPR_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX PPR_PRO_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_PROD_CATS move
 tablespace ARTIS_OBJ;

alter INDEX ICA_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX IPC_CAT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IPC_GHC_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IPC_PHC_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_RESPONSES move
 tablespace ARTIS_OBJ;

alter INDEX INR_BATCH_NUMBER_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INR_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX INR_PARENT_URN_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INR_IND_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INR_FUI_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX INR_COC_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_SEGMENTS move
 tablespace ARTIS_OBJ;

alter INDEX INS_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX INS_SET_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_SUPPRESSIONS move
 tablespace ARTIS_OBJ;

alter INDEX ISU_COM_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ISU_SUT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX ISU_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE INDIVIDUAL_VALUE move
 tablespace ARTIS_OBJ;

alter INDEX INV_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX INV_VCA_I rebuild
 tablespace ARTIS_NDX;

alter TABLE INDUSTRIES move
 tablespace ARTIS_OBJ;

alter INDEX IDS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE IND_CNY move
 tablespace ARTIS_OBJ;

alter INDEX ICM_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE JOB_NUMBERS move
 tablespace ARTIS_OBJ;

alter INDEX JNM_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE JOB_TITLES move
 tablespace ARTIS_OBJ;

alter INDEX JBT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE JOB_TITLE_VARIATIONS move
 tablespace ARTIS_OBJ;

alter INDEX JTV_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LANGUAGES move
 tablespace ARTIS_OBJ;

alter INDEX LAN_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_20030409 move
 tablespace ARTIS_OBJ;

alter INDEX LB_20030409_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_20030409B move
 tablespace ARTIS_OBJ;

alter INDEX LB_20030409B_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_20030527 move
 tablespace ARTIS_OBJ;

alter INDEX LB_20030527_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_20030527B move
 tablespace ARTIS_OBJ;

alter INDEX LB_20030527B_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_20031020 move
 tablespace ARTIS_OBJ;

alter INDEX LB_20031020_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX LB_20031204 rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_ARTICLE move
 tablespace ARTIS_OBJ;

alter INDEX LB_ARTICLE_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_ARTICLE_E move
 tablespace ARTIS_OBJ;

alter TABLE LB_DIM_GROUPS move
 tablespace ARTIS_OBJ;

alter INDEX LB_DIM_GROUPS_CARD_NR_U rebuild
 tablespace ARTIS_NDX;

alter INDEX LB_DIM_GROUPS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_DIM_THEMES move
 tablespace ARTIS_OBJ;

alter INDEX LB_DIM_THEMES_CARD_U rebuild
 tablespace ARTIS_NDX;

alter INDEX LB_DIM_THEMES_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_FACTS move
 tablespace ARTIS_OBJ;

alter INDEX LB_FACTS_CARD_U rebuild
 tablespace ARTIS_NDX;

alter INDEX LB_FACTS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LB_ORDERS move
 tablespace ARTIS_OBJ;

alter INDEX LB_ORDERS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_BATCH_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX LBD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_BATCH_HEADERS move
 tablespace ARTIS_OBJ;

alter INDEX LBH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_BATCH_RECORDS move
 tablespace ARTIS_OBJ;

alter INDEX LBR_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX LBR_QUS_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_COLUMN_ALIAS move
 tablespace ARTIS_OBJ;

alter INDEX LCA_COLUMN_ALIAS_NDX rebuild
 tablespace ARTIS_NDX;

alter INDEX LCA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_COLUMN_REFS move
 tablespace ARTIS_OBJ;

alter INDEX LCR_LTR_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX LCR_UK rebuild
 tablespace ARTIS_NDX;

alter INDEX LCR_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX LCR_LVP_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_ERROR_LOG move
 tablespace ARTIS_OBJ;

alter INDEX LEG_LBR_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX LEG_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX LEG_URN_REC_GRP_I rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_SESSION_ERRORS move
 tablespace ARTIS_OBJ;

alter TABLE LOAD_SPEC_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX LSD_ATT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX LSD_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX LSD_LOS_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_SQL_TEXT move
 tablespace ARTIS_OBJ;

alter INDEX LST_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_STATUS move
 tablespace ARTIS_OBJ;

alter INDEX LSS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_TABLE_REFS move
 tablespace ARTIS_OBJ;

alter INDEX LTR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE LOAD_VALID_PROCS move
 tablespace ARTIS_OBJ;

alter INDEX LVP_LVP2_UK rebuild
 tablespace ARTIS_NDX;

alter INDEX LVP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE MATCH_ADDRESS_POINTS move
 tablespace ARTIS_OBJ;

alter TABLE MATCH_PREF move
 tablespace ARTIS_OBJ;

alter INDEX MAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE MF03_DG_RESP move
 tablespace ARTIS_OBJ;

alter INDEX MF03_DG_RESP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE MF03_LG_RESP move
 tablespace ARTIS_OBJ;

alter INDEX MF03_LG_FAM_ID rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_LG_RESP_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_LG_PROMO_ID rebuild
 tablespace ARTIS_NDX;

alter TABLE MF03_STATS move
 tablespace ARTIS_OBJ;

alter INDEX MF03_STATS_DG_RESP rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_STATS_FAM_ID rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_STATS_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_STATS_LG_RESP rebuild
 tablespace ARTIS_NDX;

alter INDEX MF03_STATS_URN rebuild
 tablespace ARTIS_NDX;

alter TABLE NEW_APPLICATIONS_I move
 tablespace ARTIS_OBJ;

alter INDEX NAI_BATCH_NR_I rebuild
 tablespace ARTIS_NDX;

alter INDEX NAI_LOAD_DATE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX NAI_U rebuild
 tablespace ARTIS_NDX;

alter TABLE NEW_SUPPRESSIONS_I move
 tablespace ARTIS_OBJ;

alter INDEX NSI_BATCH_NR_I rebuild
 tablespace ARTIS_NDX;

alter INDEX NSI_LOAD_DATE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX NSI_U rebuild
 tablespace ARTIS_NDX;

alter TABLE OBJECT_STORAGE_SPACE move
 tablespace ARTIS_OBJ;

alter TABLE OPPORTUNITIES move
 tablespace ARTIS_OBJ;

alter INDEX OPP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUTS move
 tablespace ARTIS_OBJ;

alter INDEX OUH_OUP_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX OUH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_DATA move
 tablespace ARTIS_OBJ;

alter INDEX OUD_OUH_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX OUD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_EXTRACT_LOG move
 tablespace ARTIS_OBJ;

alter INDEX OUO_OUH_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX OUO_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_FIELDS move
 tablespace ARTIS_OBJ;

alter INDEX OUF_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_FORMAT_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX OFT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_SAMPLE_INDIVIDUALS move
 tablespace ARTIS_OBJ;

alter INDEX OSI_OUH_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX OSI_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_SEED_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX OUP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUTPUT_TRANSLATE move
 tablespace ARTIS_OBJ;

alter INDEX OUT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE OUT_ARTIS_1 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_10 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_11 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_12 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_13 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_14 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_15 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_16 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_2 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_3 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_4 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_5 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_6 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_7 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_8 move
 tablespace ARTIS_OBJ;

alter TABLE OUT_ARTIS_9 move
 tablespace ARTIS_OBJ;

alter TABLE PERSONAL_HABIT_CODES move
 tablespace ARTIS_OBJ;

alter INDEX PHC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE PLAN_TABLE move
 tablespace ARTIS_OBJ;

alter TABLE POSTCODE_GEM move
 tablespace ARTIS_OBJ;

alter INDEX POG_CITY_I rebuild
 tablespace ARTIS_NDX;

alter INDEX POG_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE POSTCODE_PROVINCE move
 tablespace ARTIS_OBJ;

alter INDEX POP_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX POP_U rebuild
 tablespace ARTIS_NDX;

alter TABLE PRODUCTS move
 tablespace ARTIS_OBJ;

alter INDEX PRO_CAT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX PRO_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE PROD_CAT_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX CAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE QUALITY_CATEGORIES move
 tablespace ARTIS_OBJ;

alter INDEX QCAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE QUALITY_CHECKS move
 tablespace ARTIS_OBJ;

alter INDEX QCH_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX QCH_QCAT_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE QUEST_ANSWERS move
 tablespace ARTIS_OBJ;

alter INDEX QUA_FUI_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX QUA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE QUEST_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX QUT_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX QUT_QUS_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE QUEST_SPEC move
 tablespace ARTIS_OBJ;

alter INDEX QUS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE QUEST_STD move
 tablespace ARTIS_OBJ;

alter INDEX QSD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE QUEST_STD_ANSWERS move
 tablespace ARTIS_OBJ;

alter INDEX QSA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE RECENT_ORDERS move
 tablespace ARTIS_OBJ;

alter INDEX REC_ORDERS_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE RELATIVES move
 tablespace ARTIS_OBJ;

alter INDEX REL_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE REPRINT_CARDS_I move
 tablespace ARTIS_OBJ;

alter INDEX RCI_BATCH_NR_I rebuild
 tablespace ARTIS_NDX;

alter INDEX RCI_LOAD_DATE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX RCI_U rebuild
 tablespace ARTIS_NDX;

alter TABLE SEGMENT_GROUP move
 tablespace ARTIS_OBJ;

alter INDEX SGR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE SEGMENT_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX SEG_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE SEL_MERKENFESTIVAL move
 tablespace ARTIS_OBJ;

alter INDEX SMF_IND_CARD_NR_I rebuild
 tablespace ARTIS_NDX;

alter INDEX SMF_IND_FAMILY_ID_I rebuild
 tablespace ARTIS_NDX;

alter INDEX SMF_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE SMF_PRIOR_RESPONDENTS move
 tablespace ARTIS_OBJ;

alter INDEX SPR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE SOP_ARCHIVED_CARDS move
 tablespace ARTIS_OBJ;

alter INDEX SAC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE SQLN_EXPLAIN_PLAN move
 tablespace ARTIS_OBJ;

alter TABLE STATS move
 tablespace ARTIS_OBJ;

alter INDEX STATS rebuild
 tablespace ARTIS_NDX;

alter TABLE STRIP_AREA_DISTRICTS move
 tablespace ARTIS_OBJ;

alter TABLE STRIP_AREA_DISTRICTS_QC move
 tablespace ARTIS_OBJ;

alter TABLE STRIP_BUILDINGS move
 tablespace ARTIS_OBJ;

alter TABLE STRIP_BUILDINGS_QC move
 tablespace ARTIS_OBJ;

alter TABLE STRIP_CHARACTERS move
 tablespace ARTIS_OBJ;

alter INDEX SCH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE STRIP_STREETS move
 tablespace ARTIS_OBJ;

alter TABLE STRIP_STREETS_QC move
 tablespace ARTIS_OBJ;

alter TABLE SUPPRESSION_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX SUT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_CELLS move
 tablespace ARTIS_OBJ;

alter INDEX TAC_CET_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX TAC_SHORT_NAME_I rebuild
 tablespace ARTIS_NDX;

alter INDEX TAC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_CELL_FUNCTION move
 tablespace ARTIS_OBJ;

alter INDEX TCF_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_CELL_INCEXC move
 tablespace ARTIS_OBJ;

alter INDEX TIE_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_CELL_INDIVIDUALS move
 tablespace ARTIS_OBJ;

alter INDEX TCI_IND_URN_I rebuild
 tablespace ARTIS_NDX;

alter INDEX TCI_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX TCI_TAC_UID_I rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_CELL_WORK move
 tablespace ARTIS_OBJ;

alter INDEX TCW_TAC_IND rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_DEFINITIONS move
 tablespace ARTIS_OBJ;

alter INDEX TAD_PCT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX TAD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TARGET_SQL_COUNTS move
 tablespace ARTIS_OBJ;

alter INDEX TSC_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TEST move
 tablespace ARTIS_OBJ;

alter TABLE TEST_FREEK move
 tablespace ARTIS_OBJ;

alter TABLE TITLES move
 tablespace ARTIS_OBJ;

alter INDEX TIT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE TMP_VALUE_ANALYSIS move
 tablespace ARTIS_OBJ;

alter TABLE TRANS_SEG_2003 move
 tablespace ARTIS_OBJ;

alter INDEX TS_2003_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE T_CAMPAIGN_ANALYSIS_COUNTS move
 tablespace ARTIS_OBJ;

alter INDEX TMP_IDX_CCC rebuild
 tablespace ARTIS_NDX;

alter TABLE T_INDIVIDUAL_BAD_WORDS move
 tablespace ARTIS_OBJ;

alter INDEX IBW_BAD_WORD_CODE_I rebuild
 tablespace ARTIS_NDX;

alter INDEX IBW_UK rebuild
 tablespace ARTIS_NDX;

alter INDEX IBW_IND_URN_I rebuild
 tablespace ARTIS_NDX;

alter TABLE T_IND_ANS move
 tablespace ARTIS_OBJ;

alter TABLE T_IND_ANS2 move
 tablespace ARTIS_OBJ;

alter INDEX TI2_BATCH_RG_I rebuild
 tablespace ARTIS_NDX;

alter TABLE T_IND_ANSWER_SUMMARY move
 tablespace ARTIS_OBJ;

alter TABLE T_NESTH_BUS_RULE move
 tablespace ARTIS_OBJ;

alter INDEX T_IND_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE T_OUTPUT_SAMPLE_REP move
 tablespace ARTIS_OBJ;

alter TABLE T_QUALITY_CHECK_COUNTS move
 tablespace ARTIS_OBJ;

alter INDEX QCC_QCH_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE T_QUEST_RESP_MILD7 move
 tablespace ARTIS_OBJ;

alter TABLE T_REPORT_JOB move
 tablespace ARTIS_OBJ;

alter TABLE T_SEGMENT_COUNTS move
 tablespace ARTIS_OBJ;

alter TABLE VALID_RACE move
 tablespace ARTIS_OBJ;

alter INDEX VAR_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_ANSWERS move
 tablespace ARTIS_OBJ;

alter INDEX VAA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_ANSWER_HEADER move
 tablespace ARTIS_OBJ;

alter INDEX VAH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_ATTRIBUTES move
 tablespace ARTIS_OBJ;

alter INDEX VAT_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_CATEGORY move
 tablespace ARTIS_OBJ;

alter INDEX VCA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_CATEGORY_GROUPS move
 tablespace ARTIS_OBJ;

alter INDEX VCG_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX VAD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_HEADER move
 tablespace ARTIS_OBJ;

alter INDEX VHD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VALUE_PARAMETERS move
 tablespace ARTIS_OBJ;

alter INDEX VAP_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VEHICLE_TYPES move
 tablespace ARTIS_OBJ;

alter INDEX VET_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE VEH_COSTS move
 tablespace ARTIS_OBJ;

alter INDEX VEX_COT_FK_I rebuild
 tablespace ARTIS_NDX;

alter INDEX VEX_PK rebuild
 tablespace ARTIS_NDX;

alter INDEX VEX_CVE_FK_I rebuild
 tablespace ARTIS_NDX;

alter TABLE XML_DOCUMENTS move
 tablespace ARTIS_OBJ;

alter INDEX XML_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE XML_DTD_ATTRIBUTES move
 tablespace ARTIS_OBJ;

alter INDEX DTDA_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE XML_DTD_DETAILS move
 tablespace ARTIS_OBJ;

alter INDEX DDTD_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE XML_DTD_HEADER move
 tablespace ARTIS_OBJ;

alter INDEX DTDH_PK rebuild
 tablespace ARTIS_NDX;

alter TABLE XML_ERROR_LOG move
 tablespace ARTIS_OBJ;

alter TABLE XML_LOAD_STATUS move
 tablespace ARTIS_OBJ;

alter INDEX XLS_PK rebuild
 tablespace ARTIS_NDX;


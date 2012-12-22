create table audit_trail
(
    username varchar2(30),
    pk number,
    attribute varchar2(30),
    dataum varchar2(255),
    timestamp date
)
/


create or replace package audit_trail_pkg
as
    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in number) return number;
                      
    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in varchar2) return varchar2;

    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in date) return date;
end;
/

create or replace package body audit_trail_pkg
as

    procedure log ( p_pk in number,
                    p_attr in varchar2,
                    p_dataum in varchar2 )

    as

        pragma autonomous_transaction;
    
    begin
        
        insert into audit_trail
        values ( user, p_pk, p_attr, p_dataum, sysdate);
        commit;

    end;
    
    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in number ) return number
    is
    
    begin
        
        log(p_pk, p_attr, p_dataum);
        return p_dataum;

    end;
    
    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in varchar2) return varchar2

    is
    
    begin
        
        log(p_pk, p_attr, p_dataum);
        return p_dataum;
        
    end;
    
    function record ( p_pk in number,
                      p_attr in varchar2,
                      p_dataum in date) return date
                      
    is
        
    begin
        
        log (p_pk, p_attr, to_char(p_dataum, 'dd/mm/yyyy hh24:mi:ss'));
        return p_dataum;
        
    end;
    
end;
/

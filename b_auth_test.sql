SELECT change_password,
       password_life_time,
       updated
  FROM b_users
 WHERE LOWER(user_id) = LOWER('admin01')
   AND delete_flg = 'N';

UPDATE b_users 
   SET change_password = 'N'
 WHERE LOWER(user_id) = LOWER('admin01')
   AND delete_flg = 'N';

declare
begin
 if b_auth.check_password_life_time('admin01',current_date) then
   dbms_output.put_line('TRUE');
 else
   dbms_output.put_line('FALSE');
 end if;
end;

SELECT change_password,
       password_life_time,
       updated
  FROM b_users
 WHERE LOWER(user_id) = LOWER('user03')
   AND delete_flg = 'N';

UPDATE b_users 
   SET change_password = 'N'
 WHERE LOWER(user_id) = LOWER('user03')
   AND delete_flg = 'N';

declare
begin
 if b_auth.check_password_life_time('user03',current_date) then -- 2019/12/25
   dbms_output.put_line('TRUE');
 else
   dbms_output.put_line('FALSE');
 end if;
end;

declare
begin
 if b_auth.check_password_life_time('user03',to_date('2021/01/01','YYYY/MM/DD')) then
   dbms_output.put_line('TRUE');
 else
   dbms_output.put_line('FALSE');
 end if;
end;

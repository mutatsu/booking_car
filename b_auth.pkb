CREATE OR REPLACE PACKAGE b_auth
AS
  -- -----------------------------------------------
  FUNCTION authentication(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN;
  -- -----------------------------------------------
  FUNCTION check_password(
    p_username             IN VARCHAR2,
    p_new_password         IN VARCHAR2,
    p_new_password_repeate IN VARCHAR2
  ) RETURN VARCHAR2;
  -- -----------------------------------------------
  FUNCTION check_password_life_time(
    p_username IN VARCHAR2,
    date_in    IN DATE DEFAULT CURRENT_DATE
  ) RETURN BOOLEAN;
  -- -----------------------------------------------
  PROCEDURE goto_password_change_page(
    p_username IN VARCHAR2,
    date_in    IN DATE DEFAULT CURRENT_DATE,
    page_in    IN VARCHAR2
  );
  -- -----------------------------------------------
  PROCEDURE set_password(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    user_id_in IN VARCHAR2
  );
  -- -----------------------------------------------
END b_auth;
/
CREATE OR REPLACE PACKAGE BODY b_auth
AS
  -- -----------------------------------------------
  FUNCTION authentication(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN
  AS
  BEGIN
    FOR i IN (
      SELECT user_id
        FROM b_users
       WHERE password = dbms_obfuscation_toolkit.md5(input_string => p_password)  
         AND LOWER(user_id) = LOWER(p_username)
         AND delete_flg = 'N'
    )LOOP
      RETURN TRUE;
    END LOOP;
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END authentication;
  -- -----------------------------------------------
  FUNCTION check_password(
    p_username             IN VARCHAR2,
    p_new_password         IN VARCHAR2,
    p_new_password_repeate IN VARCHAR2
  ) RETURN VARCHAR2
  AS
  BEGIN
    IF p_new_password != p_new_password_repeate THEN
      RETURN '新しいパスワードと新しいパスワード（再入力）が異なります。';
    END IF;
    IF authentication(p_username, p_new_password) THEN
      RETURN '同じパスワードは再設定できません。';
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_password;
  -- -----------------------------------------------
    FUNCTION check_password_life_time(
    p_username IN VARCHAR2,
    date_in    IN DATE DEFAULT CURRENT_DATE
  ) RETURN BOOLEAN
  AS
  BEGIN
    FOR i IN (
      SELECT change_password,
             password_life_time,
             updated
        FROM b_users
       WHERE LOWER(user_id) = LOWER(p_username)
         AND delete_flg = 'N'
    )LOOP
      CASE i.change_password
        WHEN 'Y' THEN
          RETURN TRUE; -- password 変更
        WHEN 'N' THEN
          -- password_life_time = 0 の時はパスワード変更対象外
          IF i.password_life_time = 0 THEN
            RETURN FALSE;
          END IF;
          IF i.updated + i.password_life_time < date_in THEN
            RETURN TRUE;
          ELSE
            RETURN FALSE;
          END IF;
        ELSE
          RETURN TRUE;
      END CASE;
    END LOOP;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END check_password_life_time;
  -- ----------------------------------------------- 
  PROCEDURE goto_password_change_page(
    p_username IN VARCHAR2,
    date_in    IN DATE DEFAULT CURRENT_DATE,
    page_in    IN VARCHAR2
  )
  AS
  BEGIN
    IF check_password_life_time(
      p_username,
      date_in
    )THEN
      APEX_UTIL.REDIRECT_URL ( APEX_PAGE.GET_URL( p_page => page_in ) );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END goto_password_change_page;
  -- -----------------------------------------------
  PROCEDURE set_password(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    user_id_in IN VARCHAR2
  )
  AS
  BEGIN
    UPDATE b_users 
       SET password = dbms_obfuscation_toolkit.md5(input_string => p_password),
           change_password = 'N',
           updated = CURRENT_DATE,
           updated_by = LOWER(user_id_in)
     WHERE LOWER(user_id) = LOWER(p_username)
       AND delete_flg = 'N';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END set_password;
END b_auth;
/

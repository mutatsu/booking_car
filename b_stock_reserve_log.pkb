CREATE OR REPLACE PACKAGE b_stock_reserve_log
AS
  EVENT_ID_TIMEOUT            VARCHAR2(1) := '0';
  EVENT_ID_RESERVE            VARCHAR2(1) := '1';
  EVENT_ID_CANCEL_RESERVATION VARCHAR2(1) := '2';
  EVENT_ID_CLOSE              VARCHAR2(1) := '3';
  EVENT_ID_CANCEL_CLOSE       VARCHAR2(1) := '4';
  PROCEDURE logging (
    stock_id_in IN NUMBER,
    event_id_in IN VARCHAR2,
    event_date_in IN DATE
  ); 
  PROCEDURE timeout_logging (
    event_date_in IN DATE
  );
END b_stock_reserve_log;
/

CREATE OR REPLACE PACKAGE BODY b_stock_reserve_log
AS
  PROCEDURE logging (
    stock_id_in IN NUMBER,
    event_id_in IN VARCHAR2,
    event_date_in IN DATE
  )AS
    rec b_stocks_log%ROWTYPE;
  BEGIN
    FOR c1 IN (
      SELECT *
        FROM b_stocks 
       WHERE stock_id = stock_id_in
    )
    LOOP

      rec.log_id                   := b_stocks_log_seq.nextval;
      rec.stock_id                 := c1.stock_id;
      rec.car_id                   := c1.car_id;
      rec.dealer_type              := c1.dealer_type;
      rec.manage_id                := c1.manage_id;
      rec.format_name              := c1.format_name;
      rec.color_cd                 := c1.color_cd;
      rec.grade                    := c1.grade;
      rec.option_list              := c1.option_list;
      rec.production_date          := c1.production_date;
      rec.registration_expiry_date := c1.registration_expiry_date;
      rec.exhibit_flg              := c1.exhibit_flg;
      rec.df_cd                    := c1.df_cd;
      rec.rank_cd                  := c1.rank_cd;
      rec.measures_comments        := c1.measures_comments;
      rec.remarks                  := c1.remarks;
      rec.in_preparation_flg       := c1.in_preparation_flg;
      rec.reservation_date         := c1.reservation_date;
      rec.reservation_deadline     := c1.reservation_deadline;
      rec.shop_id                  := c1.shop_id;
      rec.user_id                  := c1.user_id;
      rec.close_flg                := c1.close_flg;
      rec.event_id                 := event_id_in;
      rec.event_date               := event_date_in;

      INSERT INTO b_stocks_log values rec;
    END LOOP;
  END logging; 

  PROCEDURE timeout_logging (
    event_date_in IN DATE
  )AS
    rec_log b_stocks_log%ROWTYPE;
  BEGIN
    FOR c1 IN (
      SELECT stock_id
        FROM b_stocks 
       WHERE reservation_deadline < event_date_in
         AND close_flg = 'N'
    )
    LOOP
      logging (
        c1.stock_id,
        EVENT_ID_TIMEOUT,
        event_date_in
      );
      UPDATE b_stocks
         SET reservation_date = NULL,
             reservation_deadline = NULL,
             shop_id = NULL,
             user_id = NULL
       WHERE stock_id = c1.stock_id;
    END LOOP;
  END timeout_logging; 

END b_stock_reserve_log;
/

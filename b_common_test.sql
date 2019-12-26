select yyyymm_str,yyyymmdd_dt from TABLE(b_common.ret_yyyymm(TO_DATE('2019/12/26','YYYY/MM/DD')))

select yyyymm_str,yyyymmdd_dt from TABLE(b_common.ret_yyyymm(TO_DATE('2019/12/26','YYYY/MM/DD'),4))

select b_common.get_shop_name('user03') from dual;

select b_common.get_shop_id('user03') from dual;

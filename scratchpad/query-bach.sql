-- dbext:profile=haydn_local


show tables;

select id, buyer_id, status, from_unixtime(order_date) as order_date, total_amount, real_pay_amount
  from goods_order;

select t1.id,
       t1.buyer_id,
       t1.recipient_name,
       t1.status,
       from_unixtime(t1.order_date) as order_date,
       from_unixtime(t1.pay_expires_at) as pay_before,
       t1.total_amount,
       t1.real_pay_amount,
       t2.sku_id,
       t2.qty,
       t2.price,
       t2.real_pay_amount,
       t2.coupon_pay_amount,
       t2.allocation
  from goods_order t1
 inner join goods_order_line t2 on (t1.id = t2.order_id);
 order by created_at desc

select * from shipper;

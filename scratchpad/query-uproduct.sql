-- dbext:profile=uproduct_local


show tables;

select id, buyer_id, status, from_unixtime(order_date) as order_date, total_amount, real_pay_amount
  from goods_order;

select t1.id as spu_id,
       t1.title,
       t1.status,
       from_unixtime(t1.created_at) as created,
       t2.id as sku_id,
       t2.name,
       t2.price,
       t2.pictures,
       t3.type,
       t3.sub_type,
       t3.qty,
       t3.composition_factor
  from spu t1
 inner join sku t2 on (t1.id = t2.spu_id)
 inner join sku_feature t3 on (t2.id = t3.sku_id);

select * from spu;
select * from sku_feature;

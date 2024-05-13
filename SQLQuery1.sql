
--Total Orders
select count(*) as Total_Orders from fact_orders_aggregate;

--Total Order Lines
select count(*) as Total_Order_Lines from fact_order_lines;

--Total Ordered Quantity
select sum(order_qty) as Total_Ordered_Quantity from fact_order_lines;

--Total Delivered Quantity
select sum(delivery_qty) as Total_Delivered_Quantity from fact_order_lines;

--Total Quantity Not Delivered
with cte as(select sum(order_qty) as Total_Ordered_Quantity,
			sum(delivery_qty)  as Total_Delivered_Quantity
			from fact_order_lines) 
select 
		(Total_Ordered_Quantity - Total_Delivered_Quantity) as Total_Quantity_Not_Delivered
		from cte;


--OT%
with OT_Counts as (
    select  
        sum(case when on_time = 1 then 1 else 0 end) as OT_Orders,
        count(*) as Total_Orders
    from fact_orders_aggregate
)
select 
    round((cast(OT_Orders as float) / Total_Orders)*100,0) as OT_Percentage
from OT_Counts;

--IF%
with IF_Counts as (
    select  
        sum(case when in_full = 1 then 1 else 0 end) as IF_Orders,
        count(*) as Total_Orders
    from fact_orders_aggregate
)
select 
    round((cast(IF_Orders as float) / Total_Orders)*100,0) as IF_Percentage
from IF_Counts;

--OTIF%
with OTIF_Counts as (
    select  
        sum(case when otif = 1 then 1 else 0 end) as OTIF_Orders,
        count(*) as Total_Orders
    from fact_orders_aggregate
)
select 
    round((cast(OTIF_Orders as float) / Total_Orders)*100,0) as OTIF_Percentage
from OTIF_Counts;
EXEC sp_rename 'dim_targets_orders.ontime_target%', 'order_id', 'COLUMN';
EXEC sp_rename 'dim_targets_orders.column2', 'ontime_target%', 'COLUMN';
EXEC sp_rename 'dim_targets_orders.column3', 'infull_target%', 'COLUMN';
EXEC sp_rename 'dim_targets_orders.column4', 'otif_target%', 'COLUMN';
select * from dim_targets_orders;
--OT Targets
select avg([ontime_target%]) as 'Ontime_Target%' from dim_targets_orders;

--IF Targets
select avg([infull_target%]) as 'Infull_Target%' from dim_targets_orders;

--OTIF Targets
select avg([otif_target%]) as 'Otif_Targets%' from dim_targets_orders;

--LIFR%
with cte as (
    select count(*) as LIF
    from fact_order_lines
    where in_full = 1
)
select cast(LIF as float) / (select count(*) from fact_order_lines) * 100 as 'LIFR%'
from cte;

--VOFR%
with cte as(
			select sum(order_qty) as Total_QTY_ORD ,
					sum(delivery_qty) as Total_QTY_DEL
			from
				fact_order_lines)
select round((cast(Total_QTY_DEL as float)/cast(Total_QTY_ORD as float))*100,1) as 'VOFR%' from cte;

--Total Orders by city
select dc.city,count(od.customer_id) as Total_Orders
from fact_orders_aggregate od
join dim_customers dc
on od.customer_id=dc.customer_id
group by dc.city;

--Ontime Orders by city
select dc.city,sum(case when on_time = 1 then 1 else 0 end) as OT_Orders
from fact_orders_aggregate od
join dim_customers dc
on od.customer_id=dc.customer_id
group by dc.city;

--InFull Orders by city
select dc.city,sum(case when in_full = 1 then 1 else 0 end) as IF_Orders
from fact_orders_aggregate od
join dim_customers dc
on od.customer_id=dc.customer_id
group by dc.city;

--OTIF Orders by city
select dc.city,sum(case when otif = 1 then 1 else 0 end) as OTIF_Orders
from fact_orders_aggregate od
join dim_customers dc
on od.customer_id=dc.customer_id
group by dc.city;

--delivery details
with cte as	(select
		*,
		datediff(DAY, agreed_delivery_date, actual_delivery_date) as delivery_delay
	from 
		fact_order_lines)
select count(order_id) as count , delivery_delay
from cte
group by delivery_delay;

--OT% by city 
with OT_Counts as (
    select  
		dc.city,
        sum(case when od.on_time = 1 then 1 else 0 end) as OT_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_customers dc
	on od.customer_id=dc.customer_id
	group by dc.city
)
select 
    city,round((cast(OT_Orders as float) / Total_Orders)*100,0) as OT_Percentage
from OT_Counts;

--IF% by city
with IF_Counts as (
    select  
		dc.city,
        sum(case when od.in_full = 1 then 1 else 0 end) as IF_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_customers dc
	on od.customer_id=dc.customer_id
	group by dc.city
)
select 
    city,round((cast(IF_Orders as float) / Total_Orders)*100,0) as IF_Percentage
from IF_Counts;

--OTIF% by city
with OTIF_Counts as (
    select  
		dc.city,
        sum(case when od.otif = 1 then 1 else 0 end) as OTIF_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_customers dc
	on od.customer_id=dc.customer_id
	group by dc.city
)
select 
    city,round((cast(OTIF_Orders as float) / Total_Orders)*100,0) as IF_Percentage
from OTIF_Counts;

--OT% by week
with OT_Counts as (
    select  
		d.week_no,
        sum(case when od.on_time = 1 then 1 else 0 end) as OT_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_date d
	on od.order_placement_date=d.date
	group by d.week_no
)
select 
    week_no,round((cast(OT_Orders as float) / Total_Orders)*100,0) as OT_Percentage
from OT_Counts;

--IF% by week
with IF_Counts as (
    select  
		d.week_no,
        sum(case when od.in_full = 1 then 1 else 0 end) as IF_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_date d
	on od.order_placement_date=d.date
	group by d.week_no
)
select 
    week_no,round((cast(IF_Orders as float) / Total_Orders)*100,0) as IF_Percentage
from IF_Counts;

--OTIF% by week
with OTIF_Counts as (
    select  
		d.week_no,
        sum(case when od.otif = 1 then 1 else 0 end) as OTIF_Orders,
        count(od.order_id) as Total_Orders
    from fact_orders_aggregate od
	join dim_date d
	on od.order_placement_date=d.date
	group by d.week_no
)
select 
    week_no,round((cast(OTIF_Orders as float) / Total_Orders)*100,0) as IF_Percentage
from OTIF_Counts;

--LIFR% by week
with cte as (
    select dd.week_no, count(*) as lif
    from fact_order_lines ol
    join dim_date dd
    on ol.order_placement_date = dd.date
    where ol.in_full = 1
    group by dd.week_no
)
select total_orders.week_no,round((cast(lif as float) / total_orders.total_count) * 100,0) as "lifr%"
from cte
join (
    select x.week_no, count(ol.order_id) as total_count
    from fact_order_lines ol
    join dim_date x
    on ol.order_placement_date = x.date
    group by x.week_no
) as total_orders on cte.week_no = total_orders.week_no;

--VOFR% by week
with cte as(
			select y.week_no,sum(x.order_qty) as Total_QTY_ORD ,
					sum(x.delivery_qty) as Total_QTY_DEL
			from
				fact_order_lines x
			join
				dim_date y
			on
				x.order_placement_date=y.date
			group by y.week_no)
select week_no,round((cast(Total_QTY_DEL as float)/cast(Total_QTY_ORD as float))*100,1) as 'VOFR%' from cte;

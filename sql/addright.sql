#replace user_rights (person_id, topic_id,project_id, adm, RW, project_name )  
#	(select :pers_id, topic_id,  id, 1,2, short_name
#	from projects where topic_id =':topic');

#select * from projects where id in 
#(select project_id from user_rights ur where ur.person_id=:pers_id);

select * from user_rights ur where ur.person_id=:pers_id;


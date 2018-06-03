
#insert user_rights (person_id, topic_id,project_id, adm, RW )  values(878, 
	(select topic_id from projects where short_name =':p1'),
	 (select id from projects where short_name =':p1'),
	 1,1);




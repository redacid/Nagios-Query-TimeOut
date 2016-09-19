use admin
db.auth('root','password')
use mi
rs.slaveOk()
db.mi_en_news.find().limit(1)

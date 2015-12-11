@Kifu = new Mongo.Collection("kifu")
Kifu.allow
    insert: -> isAdmin()
    update: -> isAdmin()
    remove: -> isAdmin()

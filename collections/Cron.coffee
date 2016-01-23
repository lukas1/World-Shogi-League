@Cron = new Mongo.Collection("cron")
Cron.allow
    insert: -> false
    update: -> false
    remove: -> false

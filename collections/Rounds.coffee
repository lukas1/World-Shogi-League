@Rounds = new Mongo.Collection("rounds")
Rounds.allow
    insert: -> isAdmin()
    update: -> isAdmin()
    remove: -> isAdmin()

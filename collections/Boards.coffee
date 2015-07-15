@Boards = new Mongo.Collection "boards";
Boards.allow
    insert: -> isAdminOrHead()
    update: -> isAdminOrHead()
    remove: -> isAdminOrHead()

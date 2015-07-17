BoardsCollection = Mongo.Collection;

BoardsCollection.prototype.removeBoard = (filter) ->
    this.remove filter

@Boards = new BoardsCollection "boards";
Boards.allow
    insert: -> isAdminOrHead()
    update: -> isAdminOrHead()
    remove: -> isAdminOrHead()

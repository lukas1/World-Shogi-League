Template.navbar.helpers
    isAdmin: () ->
        isAdmin()
    isAdminOrHead: () ->
        isAdminOrHead()
    canScheduleMatch: () ->
        try
            throw new Meteor.Error "not-authorized" if not Meteor.userId()?
            board = boardDataForPlayerId Meteor.userId()
            throw new Meteor.Error "not-authorized" if not board?

            return true
        catch error
            return false

Template.navbar.events
    "click #logoutButton": (event, template) ->
        Meteor.logout ->
            Router.go('home')

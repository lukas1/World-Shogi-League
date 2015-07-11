Template.navbar.helpers
    isAdmin: () ->
        userType = Meteor.user()?.profile?.userType
        return userType == 'admin'        
    isAdminOrHead: () ->
        userType = Meteor.user()?.profile?.userType
        return userType == 'admin' or userType == 'head'

Template.navbar.events
    "click #logoutButton": (event, template) ->
        Meteor.logout ->
            Router.go('home')

Template.navbar.helpers
    isAdmin: () ->
        isAdmin()
    isAdminOrHead: () ->
        isAdminOrHead()

Template.navbar.events
    "click #logoutButton": (event, template) ->
        Meteor.logout ->
            Router.go('home')

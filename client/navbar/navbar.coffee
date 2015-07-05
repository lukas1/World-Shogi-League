Template.navbar.events
    "click #logoutButton": (event, template) ->
        Meteor.logout ->
            Router.go('home')

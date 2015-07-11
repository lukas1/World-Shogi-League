Router.configure({
    layoutTemplate:"applicationLayout"
})

Router.route(Routes.home.path,
    waitOn: () ->
        return [
            Meteor.subscribe "matches"
            Meteor.subscribe "teams"
        ]
    name: Routes.home.name
    action: ->
        this.render Routes.home.template
)

Router.route(Routes.login.path,
    name: Routes.login.name
    action: ->
        if not Meteor.user()?
            this.render Routes.login.template
        else
            this.render Routes.oops.template
)

Router.route(Routes.registration.path,
    waitOn: () ->
        return Meteor.subscribe "teams"

    name: Routes.registration.name
    action: ->
        if not Meteor.user()?
            this.render Routes.registration.template
        else
            this.render Routes.oops.template
)

Router.route(Routes.teamsEdit.path,
    waitOn: () ->
        return [
            Meteor.subscribe "teams"
            Meteor.subscribe "matches"
        ] if isAdmin()
    name: Routes.teamsEdit.name
    action: () ->
        if isAdmin()
            this.render Routes.teamsEdit.template
        else
            this.render Routes.oops.template
)

Router.route(Routes.userList.path,
    waitOn: () ->
        return [
            Meteor.subscribe "userlist"
            Meteor.subscribe "teams"
        ] if isAdminOrHead()
    name: Routes.userList.name
    action: () ->
        if isAdminOrHead()
            this.render Routes.userList.template
        else
            this.render Routes.oops.template
)

Router.route(Routes.updateUser.path,
    waitOn: () ->
        return Meteor.subscribe "teams"

    name: Routes.updateUser.name
    action: ->
        if Meteor.user()?
            this.render Routes.updateUser.template
        else
            this.render Routes.oops.template
)

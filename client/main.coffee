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
        this.render(Routes.home.template);
)

Router.route(Routes.login.path, () ->
    this.render(Routes.login.template);
)

Router.route(Routes.registration.path,
    waitOn: () ->
        return Meteor.subscribe "teams"

    name: Routes.registration.name
    action: ->
        this.render(Routes.registration.template);
)

Router.route(Routes.teamsEdit.path,
    waitOn: () ->
        return [
            Meteor.subscribe "teams"
            Meteor.subscribe "matches"
        ]
    name: Routes.teamsEdit.name
    action: () ->
        this.render(Routes.teamsEdit.template);
)

Router.route(Routes.updateUser.path, (() ->
    this.render(Routes.updateUser.template);
    )
    { name: Routes.updateUser.name }
)

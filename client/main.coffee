Router.configure
    layoutTemplate: "applicationLayout"
    subscriptions: () ->
        this.subscribe "lastRound"
        this.subscribe "currentMatches"
        this.subscribe "myMatchCurrentBoards"

Router.route(Routes.home.path,
    waitOn: () ->
        return [
            Meteor.subscribe "rounds"
            Meteor.subscribe "matches"
            Meteor.subscribe "teams"
        ]
    name: Routes.home.name
    action: ->
        this.render Routes.home.template
)

Router.route(Routes.games.path,
    waitOn: () ->
        params = this.params; # { _id: "id_of_match" }
        return [
            Meteor.subscribe "thisMatch", params._id
            Meteor.subscribe "matchTeams", params._id
            Meteor.subscribe "matchBoards", params._id
            Meteor.subscribe "matchParticipants", params._id
        ]
    name: Routes.games.name
    action: () ->
        routerThis = this
        this.render Routes.games.template,
            data: () ->
                return { params: routerThis.params }
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

Router.route(Routes.teamProfile.path,
    waitOn: () ->
        params = this.params; # { _id: "id_of_team" }
        return [
            Meteor.subscribe "teams"
            Meteor.subscribe "rounds"
            Meteor.subscribe "teamMatches", params._id
            Meteor.subscribe "teamBoards", params._id
            Meteor.subscribe "teamMembers", params._id
        ]
    name: Routes.teamProfile.name
    action: () ->
        routerThis = this
        this.render Routes.teamProfile.template,
            data: () ->
                return { params: routerThis.params }
)

Router.route(Routes.scheduleMatch.path,
    waitOn: () ->
        return [
            Meteor.subscribe "myMatchPlayers"
            Meteor.subscribe "lastRound"
            Meteor.subscribe "teams"
            Meteor.subscribe "currentMatches"
            Meteor.subscribe "currentBoards"
        ]
    name: Routes.scheduleMatch.name
    action: () ->
        try
            throw new Meteor.Error "not-authorized" if not Meteor.userId()?
            board = boardDataForPlayerId Meteor.userId()
            throw new Meteor.Error "not-authorized" if not board?

            this.render Routes.scheduleMatch.template
        catch error
            this.render Routes.oops.template
)

Router.route(Routes.userList.path,
    waitOn: () ->
        return [
            Meteor.subscribe "userlist"
            Meteor.subscribe "lastRound"
            Meteor.subscribe "teams"
            Meteor.subscribe "currentMatches"
            Meteor.subscribe "myMatchCurrentBoards"
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

Router.route(Routes.userProfile.path,
    waitOn: () ->
        params = this.params; # { _id: "id_of_user" }
        return [
            Meteor.subscribe "userProfileData", params._id
            Meteor.subscribe "userBoards", params._id
        ]
    name: Routes.userProfile.name
    action: () ->
        routerThis = this
        this.render Routes.userProfile.template,
            data: () ->
                return { params: routerThis.params }
)

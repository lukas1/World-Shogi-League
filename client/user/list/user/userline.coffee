showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#errorMessageContainer').get(0)

Template.userline.helpers
    profilePic: ->
        profilePic = Template.instance().data.profile?.profilePic
        profilePic = "/images/default-profile-pic.png" if not profilePic?.length
        return profilePic
    nick81Dojo: ->
        nick81Dojo = Template.instance().data.profile?.nick81Dojo
        nick81Dojo = "unknown" if not nick81Dojo?.length
        return nick81Dojo
    teamName: ->
        country = Teams.findOne(Template.instance().data.profile?.teamId)?.name
        country = "unknown" if not country?.length
        return country
    teamCountryCode: ->
        Teams.findOne(Template.instance().data.profile?.teamId)?.countryCode
    isAdmin: ->
        isAdmin()
    userIsAdmin: ->
        userId = Template.instance().data._id
        userType = Meteor.users.findOne(userId)?.profile?.userType
        return userType == USER_TYPE_ADMIN
    userIsHead: ->
        userId = Template.instance().data._id
        userType = Meteor.users.findOne(userId)?.profile?.userType
        return userType == USER_TYPE_HEAD

Template.userline.events
    "click .delete": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to remove this user? This action cannot be reversed"
            Meteor.call "removeUser", tpl.data._id, (error) ->
                if error
                    return showError "Removing user failed!", error.reason

    "click .makeAdmin": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to make this user an admin?"
            Meteor.call "makeAdmin", tpl.data._id, (error) ->
                if error
                    return showError "Can't make user an admin!", error.reason
    "click .makeHead": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to make this user a team head?"
            Meteor.call "makeHead", tpl.data._id, (error) ->
                if error
                    return showError "Can't make user a team head!", error.reason

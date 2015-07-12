@isAdmin = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN

@isHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_HEAD

@isAdminOrHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN or userType == USER_TYPE_HEAD

@lastRound = () ->
    rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
    return null if not rounds?.length
    return rounds[0];

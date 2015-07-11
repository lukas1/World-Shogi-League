@isAdmin = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN

@isHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_HEAD

@isAdminOrHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN or userType == USER_TYPE_HEAD

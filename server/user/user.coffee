checkProfilePic = (profilePic) ->
    return false if not profilePic?.length
    if profilePic.length > 5000000 # 5 MB
        throw new Meteor.Error "profile-pic-size", "Accepting only images
        smaller than 5MB."

    if profilePic.indexOf('image') == -1
        throw new Meteor.Error "profile-pic-type", "Uploaded file is not
        an image."

Accounts.onCreateUser (options, user) ->
    checkProfilePic options.profile?.profilePic

    if not options.profile?.nick81Dojo?.length
        throw new Meteor.Error "profile-empty-81dojo",
        "Please specify your 81dojo.com nickname"

    if not options.profile?.teamId?.length and
    options.profile?.userType != USER_TYPE_ADMIN
        throw new Meteor.Error "profile-empty-teamId",
        "Please select which country you represent"

    user.profile = {}
    user.profile = options.profile if options.profile?
    return user

setUserType = (userId, type) ->
    throw new Meteor.Error "not-authorized" if not isAdmin()
    profile = Meteor.users.findOne(userId)?.profile
    profile = {} if not profile?
    if profile.userType == USER_TYPE_ADMIN
        throw new Meteor.Error "demote-disabled" 
    profile.userType = type
    Meteor.users.update { _id: userId }, { $set: { 'profile': profile } }

Meteor.methods
    registerUser: (regOptions) ->
        uploadProfilePic regOptions?.profile?.profilePic, (profilePicPath) ->
            regOptions.profile.profilePic = profilePicPath if profilePicPath?

            Accounts.createUser regOptions

    updateProfile: (userId, profile) ->
        throw new Meteor.Error "not-authorized" if Meteor.userId() != userId
        checkProfilePic profile?.profilePic

        uploadProfilePic profile?.profilePic, (profilePicPath) ->
            profile.profilePic = profilePicPath if profilePicPath?

            Meteor.users.update { _id: userId }, { $set: { 'profile': profile } }
    removeUser: (userId) ->
        errorReason = ''
        allow = false;
        allow = true if isAdmin()

        userToRemove = Meteor.users.findOne userId
        if isHead()
            if userToRemove?.profile?.teamId == Meteor.user().profile.teamId
                if userToRemove?.profile?.userType == USER_TYPE_HEAD
                    errorReason = "Only admins can remove team heads. Contact
                    admin in case you need to remove this user"
                else
                    allow = true
        allow = false if userToRemove?.profile?.userType == USER_TYPE_ADMIN

        throw new Meteor.Error "not-authorized", errorReason if not allow
        Meteor.users.remove userId
    makeAdmin: (userId) ->
        setUserType userId, USER_TYPE_ADMIN
    makeHead: (userId) ->
        setUserType userId, USER_TYPE_HEAD
    unHead: (userId) ->
        setUserType userId, null

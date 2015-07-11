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

    if not options.profile?.teamId?.length
        throw new Meteor.Error "profile-empty-teamId",
        "Please select which country you represent"

    user.profile = {}
    user.profile = options.profile if options.profile?
    return user

Meteor.methods
    updateProfile: (userId, profile) ->
        throw new Meteor.Error "not-authorized" if Meteor.userId() != userId
        checkProfilePic profile?.profilePic
        Meteor.users.update { _id: userId }, { $set: { 'profile': profile } }
    removeUser: (userId) ->
        throw new Meteor.Error "not-authorized" if not Meteor.userId()
        Meteor.users.remove userId

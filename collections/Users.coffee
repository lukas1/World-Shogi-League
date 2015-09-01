# This is a hack, but there's probably no other better way to achieve this
Meteor.users._transform = (doc) ->
    if not doc?.profile?.profilePic?.length
        doc?.profile['profilePic'] = "/images/default-profile-pic.png"
    return doc

###

This is a sample file for uploading profile picture.
This code will basically just return the picture data to be
stored directly into database. This works, however every time user data is
fetched, 1MB or so of the uploaded picture is fetched as well. This slows down
loading of the page, because we can't do asynchronous download of the picture
and the picture is not being cached. Pretty much a disaster. Because of issues
with uploading pictures to a server with Meteor.js and free hostings, you should
probably implement a file uploading functionality on some remote server and
use this method to upload the picture data there and the server should return
link to the newly stored profile picture. The effort will be rewarded by much
faster page load times.

@uploadProfilePic = (pictureData, callback) ->
    callback(pictureData)
###

class @EmailSender

    sendEmail: (to, subject, body) ->

        senderEmail = SENDER_EMAIL()
        if senderEmail?.length == 0
            senderEmail = "test@test.com"

        Email.send
            from: senderEmail
            to: to
            subject: subject
            text: body

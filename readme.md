# AzPWPush

AzPwPush is a password push tool that can be used to generate URLs with a one-time password. Use cases are sharing temporary credentials or validating someone's access.

It's possible to use both generated passwords, or self-entered passwords.

## How it works

When deploying this function to Azure, the function will have 3 URLS

/Generate - Generates a password from a 10000 word wordlist. The password will exists out of 3 words, and 5 random characters.

/Create - Creates a unique password and URL/

/Get - allows you to retrieve the password. The password will also immediately be destroyed, invalidating the URL for future use.

A Cleanup function runs every hour to clean up the old password files. This is done based on the Maximum Age.

## Todo

<TODO> Documentation :(

wheniwork-api-ruby
=================

You probably don't want to use this
------------

There's an official-looking client here: https://github.com/parcelbright/wheniwork.

About
------------

This is a very thin When I Work API wrapper for Ruby. Based on [wheniwork-api-php](https://github.com/dolfelt/wheniwork-api-php).

It probably works. I don't have a developer key to test with.

Requires Ruby 1.9.2.

Installation
------------

* git clone https://github.com/rparrett/wheniwork-api-ruby.git
* cd wheniwork-api-ruby
* gem build wheniwork-api-ruby.gemspec
* gem install wheniwork-api-ruby

Examples
--------

Login (requires Developer Key) to obtain an api token

```ruby
response = Wheniwork.login('developer_key', 'rob@example.com', 'password')

wiw = Wheniwork.new(response['login']['token'])
```

List users (/users/ method)

```ruby
wiw = WhenIWork.new('api-token-here')
response = wiw.get('users')
```

Create a new user

```ruby
wiw = WhenIWork.new('api-token-here')
user = {
	"email" => "user.mcuserton@example.com",
	"first_name" => "User",
	"last_name" => "McUserton",
	"phone_number" => "+15551234567"
}

response = wiw.create('users', user)
```

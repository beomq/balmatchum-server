import 'dart:convert';

/// Public disposable credentials. Never use these in a deployed server.
Map<String, String> socialTestPasswords() => {
  'googleClientSecret': jsonEncode({
    'web': {
      'client_id': 'test-google-client',
      'client_secret': 'public-test-secret',
      'redirect_uris': ['https://example.test/callback'],
    },
  }),
  'appleServiceIdentifier': 'test.apple.service',
  'appleBundleIdentifier': 'test.apple.bundle',
  'appleRedirectUri': 'https://example.test/apple/callback',
  'appleTeamId': 'TESTTEAM01',
  'appleKeyId': 'TESTKEY001',
  'appleKey': '''
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgj6+aqtQ7rehYRGu2
UZK3ZhMyT4kmqCr4BqxxgCQ29NGhRANCAASwrTtVnKjyvmYT9vwScZmGECjy7f7Y
7euwg5DATdL1fuLhbvPm2wJMKY9YfO2emJbz6IW8id8OJBpXjgyXgTl6
-----END PRIVATE KEY-----
''',
};

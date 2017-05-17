var _panosoft$elm_emailer$Native_Emailer;
(function() {
	// Elm globals (some for elm-native-helpers and some for us and some for the future)
	const E = {
		A2: A2,
		A3: A3,
		A4: A4,
		Scheduler: {
			nativeBinding: _elm_lang$core$Native_Scheduler.nativeBinding,
			succeed:  _elm_lang$core$Native_Scheduler.succeed,
			fail: _elm_lang$core$Native_Scheduler.fail,
			rawSpawn: _elm_lang$core$Native_Scheduler.rawSpawn
		},
		List: {
			fromArray: _elm_lang$core$Native_List.fromArray
		},
		Maybe: {
			Nothing: _elm_lang$core$Maybe$Nothing,
			Just: _elm_lang$core$Maybe$Just
		},
		Result: {
			Err: _elm_lang$core$Result$Err,
			Ok: _elm_lang$core$Result$Ok
		}
	};
	// This module is in the same scope as Elm but all modules that are required are NOT
	// So we must pass elm globals to it (see https://github.com/panosoft/elm-native-helpers for the minimum of E)
	const helper = require('@panosoft/elm-native-helpers/helper')(E);
	_panosoft$elm_emailer$Native_Emailer = function() {
		const nodemailer = require('nodemailer');
		const _createTransporter = (host, port, auth, secure, debug) => {
			var transporterOptions = {host: host, secure: secure, debug: debug};
			if (port) {
				transporterOptions.port = port;
			}
			if (auth) {
				transporterOptions.auth = {user: auth.user, pass: auth.pass};
			}
			if (debug) {
				transporterOptions.logger = require('bunyan').createLogger({name: 'Emailer'});
			}
			return nodemailer.createTransport(transporterOptions);
		};
		const _mailOptions = (options) => {
			const validTypes = {
				text: 'TextMessage',
				html: 'HtmlMessage'
			}
			const newOptions = {to: options.to, from: options.from, subject: options.subject};
			if (options.message.ctor === validTypes.text) {
				newOptions.text = options.message['_0'];
			}
			else if (options.message.ctor === validTypes.html) {
				newOptions.html = options.message['_0'];
			}
			else {
				throw new Error('Undefined EmailMessage type:  ' + options.message.ctor + '    Valid EmailMessage types:  '
					+ (Object.keys(validTypes).map(key => validTypes[key])));
			}
			return newOptions;
		};
	    //////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Cmds
	    const _send = (host, port, auth, secure, debug, options, cb) => {
	        try {
				const transporter = _createTransporter(host, port, auth, secure, debug);
				const mailOptions = _mailOptions(options);
				transporter.sendMail(mailOptions, function(err, info) {
				    if(err) {
						cb(err);
				    }
					else {
						cb(null, info.response);
				    };
				});
	        }
	        catch (err) {
	            cb(err.message)
	        }
	    };
	    const send = helper.call6_1(_send, helper.unwrap({2: '_0', 3:'_0'}));
		return {
			///////////////////////////////////////////
			// Cmds
	        send: F7(send)
			///////////////////////////////////////////
			// Subs
		};

	}();
})();

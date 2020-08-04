import Flutter
import UIKit
import Mixpanel

public class SwiftFluttermixpanelPlugin: NSObject, FlutterPlugin {

    var mixpanel: MixpanelInstance?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "g123k/fluttermixpanel", binaryMessenger: registrar.messenger())
        let instance = SwiftFluttermixpanelPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! NSDictionary
        let token = (args["token"] as! String)

        if (token.isEmpty) {
            result(FlutterError.init(code: "NOT_INITIALIZED", message: "Please initialize the Mixpanel API first with a valid token", details: nil))
            return
        }
        if (call.method == "initialize") {
            initialize(result: result, token: token)
        } else if let mixpanel = self.mixpanel {
            switch (call.method) {
            case "track":
                track(args: args, result: result, mixpanel: mixpanel)
            case "track_map":
                trackMap(args: args, result: result, mixpanel: mixpanel)
            case "track_json":
                trackJson(args: args, result: result, mixpanel: mixpanel)
            case "get_distinct_id":
                getDistinctId(result: result, mixpanel: mixpanel)
            case "flush":
                flush(result: result, mixpanel: mixpanel)
            case "alias":
                alias(args: args, result: result, mixpanel: mixpanel)
            case "identify":
                identify(args: args, result: result, mixpanel: mixpanel)
            case "reset":
                reset(result: result, mixpanel: mixpanel)
            case "people/set":
                peopleSet(args: args, result: result, mixpanel: mixpanel)
            case "people/identify":
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }

            mixpanel.flush()
        }
    }

    func initialize(result: @escaping FlutterResult, token: String) {
        mixpanel = Mixpanel.initialize(token: token)
        result(nil)
    }

    func peopleSet(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        mixpanel.people.set(properties: ["\(args["property_name"] as! String)": "\(args["value"] as! String)"])
        result(nil)
    }

    func reset(result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        mixpanel.reset()
        result(nil)
    }

    func alias(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        let alias = (args["alias"] as! String)
        let original = (args["original"] as! String)

        if (alias.isEmpty || original.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "Alias and original can't be empty", details: nil))
            return
        }

        mixpanel.createAlias(alias, distinctId: original)
        result(nil)
    }

    func identify(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        let distinctId = (args["distinct_id"] as! String)

        if (distinctId.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "Distinct id cannot be empty", details: nil))
            return
        }

        mixpanel.identify(distinctId: distinctId)
        result(nil)
    }

    func track(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        let eventName = (args["event_name"] as! String)

        if (eventName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        }

        mixpanel.track(event: eventName)
        result(nil)
    }

    func trackMap(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {

        guard
            let eventName = args["event_name"] as? String,
            !eventName.isEmpty
            else {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        }

        guard let propertiesMap = args["properties_map"] as? NSDictionary else {
            result(FlutterError.init(code: "ERROR", message: "The properties map argument is missing!", details: nil))
            return
        }

        var properties = [String: MixpanelType]()
        for (k, v) in propertiesMap {
            if
                let key = k as? String,
                let value = castToMixpanelType(value: v) {
                properties[key] = value
            }
        }

        mixpanel.track(event: eventName, properties: properties)

        result(nil)
    }

    func trackJson(args: NSDictionary, result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        print(args)

        let eventName = (args["event_name"] as! String)
        let propertiesJson = (args["properties_json"] as? String)

        if (eventName.isEmpty) {
            result(FlutterError.init(code: "ERROR", message: "The event name argument is missing!", details: nil))
            return
        } else if (propertiesJson == nil) {
            result(FlutterError.init(code: "ERROR", message: "The properties map argument is missing!", details: nil))
            return
        }

        let props = convertToDictionary(text: propertiesJson as! String)
        print(props)

        mixpanel.track(event: eventName, properties: props as! Dictionary<String, String>)
        result(nil)
    }

    func getDistinctId(result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        result(mixpanel.distinctId)
    }

    func flush(result: @escaping FlutterResult, mixpanel: MixpanelInstance) {
        mixpanel.flush()
        result(nil)
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func castToMixpanelType(value: Any) -> MixpanelType? {
        if value is String {
            return value as? String
        }
        if value is Int {
            return value as? Int
        }
        if value is UInt {
            return value as? UInt
        }
        if value is Double {
            return value as? Double
        }
        if value is Float {
            return value as? Float
        }
        if value is Bool {
            return value as? Bool
        }
        if value is [Any] {
            return value as? [MixpanelType]
        }
        if value is [String: Any] {
            return value as? [String: MixpanelType]
        }
        if value is Date {
            return value as? Date
        }
        if value is URL {
            return value as? URL
        }
        return nil
    }
}

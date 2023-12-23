#
# config/crd/experimental/gateway.networking.k8s.io_gateways.yaml
#
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    api-approved.kubernetes.io: https://github.com/kubernetes-sigs/gateway-api/pull/2466
    gateway.networking.k8s.io/bundle-version: v1.0.0
    gateway.networking.k8s.io/channel: experimental
  name: gateways.gateway.networking.k8s.io
spec:
  group: gateway.networking.k8s.io
  names:
    categories:
      - gateway-api
    kind: Gateway
    listKind: GatewayList
    plural: gateways
    shortNames:
      - gtw
    singular: gateway
  scope: Namespaced
  versions:
    - additionalPrinterColumns:
        - jsonPath: .spec.gatewayClassName
          name: Class
          type: string
        - jsonPath: .status.addresses[*].value
          name: Address
          type: string
        - jsonPath: .status.conditions[?(@.type=="Programmed")].status
          name: Programmed
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1
      schema:
        openAPIV3Schema:
          description: Gateway represents an instance of a service-traffic handling infrastructure by binding Listeners to a set of IP addresses.
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of Gateway.
              properties:
                addresses:
                  description: "Addresses requested for this Gateway. This is optional and behavior can depend on the implementation. If a value is set in the spec and the requested address is invalid or unavailable, the implementation MUST indicate this in the associated entry in GatewayStatus.Addresses. \n The Addresses field represents a request for the address(es) on the \"outside of the Gateway\", that traffic bound for this Gateway will use. This could be the IP address or hostname of an external load balancer or other networking infrastructure, or some other address that traffic will be sent to. \n If no Addresses are specified, the implementation MAY schedule the Gateway in an implementation-specific manner, assigning an appropriate set of Addresses. \n The implementation MUST bind all Listeners to every GatewayAddress that it assigns to the Gateway and add a corresponding entry in GatewayStatus.Addresses. \n Support: Extended \n "
                  items:
                    description: GatewayAddress describes an address that can be bound to a Gateway.
                    oneOf:
                      - properties:
                          type:
                            enum:
                              - IPAddress
                          value:
                            anyOf:
                              - format: ipv4
                              - format: ipv6
                      - properties:
                          type:
                            not:
                              enum:
                                - IPAddress
                    properties:
                      type:
                        default: IPAddress
                        description: Type of the address.
                        maxLength: 253
                        minLength: 1
                        pattern: ^Hostname|IPAddress|NamedAddress|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                        type: string
                      value:
                        description: "Value of the address. The validity of the values will depend on the type and support by the controller. \n Examples: `1.2.3.4`, `128::1`, `my-ip-address`."
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - value
                    type: object
                    x-kubernetes-validations:
                      - message: Hostname value must only contain valid characters (matching ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$)
                        rule: 'self.type == ''Hostname'' ? self.value.matches(r"""^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"""): true'
                  maxItems: 16
                  type: array
                  x-kubernetes-validations:
                    - message: IPAddress values must be unique
                      rule: "self.all(a1, a1.type == 'IPAddress' ? self.exists_one(a2, a2.type == a1.type && a2.value == a1.value) : true )"
                    - message: Hostname values must be unique
                      rule: "self.all(a1, a1.type == 'Hostname' ? self.exists_one(a2, a2.type == a1.type && a2.value == a1.value) : true )"
                gatewayClassName:
                  description: GatewayClassName used for this Gateway. This is the name of a GatewayClass resource.
                  maxLength: 253
                  minLength: 1
                  type: string
                infrastructure:
                  description: "Infrastructure defines infrastructure level attributes about this Gateway instance. \n Support: Core \n "
                  properties:
                    annotations:
                      additionalProperties:
                        description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                        maxLength: 4096
                        minLength: 0
                        type: string
                      description: "Annotations that SHOULD be applied to any resources created in response to this Gateway. \n For implementations creating other Kubernetes objects, this should be the `metadata.annotations` field on resources. For other implementations, this refers to any relevant (implementation specific) \"annotations\" concepts. \n An implementation may chose to add additional implementation-specific annotations as they see fit. \n Support: Extended"
                      maxProperties: 8
                      type: object
                    labels:
                      additionalProperties:
                        description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                        maxLength: 4096
                        minLength: 0
                        type: string
                      description: "Labels that SHOULD be applied to any resources created in response to this Gateway. \n For implementations creating other Kubernetes objects, this should be the `metadata.labels` field on resources. For other implementations, this refers to any relevant (implementation specific) \"labels\" concepts. \n An implementation may chose to add additional implementation-specific labels as they see fit. \n Support: Extended"
                      maxProperties: 8
                      type: object
                  type: object
                listeners:
                  description: "Listeners associated with this Gateway. Listeners define logical endpoints that are bound on this Gateway's addresses. At least one Listener MUST be specified. \n Each Listener in a set of Listeners (for example, in a single Gateway) MUST be _distinct_, in that a traffic flow MUST be able to be assigned to exactly one listener. (This section uses \"set of Listeners\" rather than \"Listeners in a single Gateway\" because implementations MAY merge configuration from multiple Gateways onto a single data plane, and these rules _also_ apply in that case). \n Practically, this means that each listener in a set MUST have a unique combination of Port, Protocol, and, if supported by the protocol, Hostname. \n Some combinations of port, protocol, and TLS settings are considered Core support and MUST be supported by implementations based on their targeted conformance profile: \n HTTP Profile \n 1. HTTPRoute, Port: 80, Protocol: HTTP 2. HTTPRoute, Port: 443, Protocol: HTTPS, TLS Mode: Terminate, TLS keypair provided \n TLS Profile \n 1. TLSRoute, Port: 443, Protocol: TLS, TLS Mode: Passthrough \n \"Distinct\" Listeners have the following property: \n The implementation can match inbound requests to a single distinct Listener. When multiple Listeners share values for fields (for example, two Listeners with the same Port value), the implementation can match requests to only one of the Listeners using other Listener fields. \n For example, the following Listener scenarios are distinct: \n 1. Multiple Listeners with the same Port that all use the \"HTTP\" Protocol that all have unique Hostname values. 2. Multiple Listeners with the same Port that use either the \"HTTPS\" or \"TLS\" Protocol that all have unique Hostname values. 3. A mixture of \"TCP\" and \"UDP\" Protocol Listeners, where no Listener with the same Protocol has the same Port value. \n Some fields in the Listener struct have possible values that affect whether the Listener is distinct. Hostname is particularly relevant for HTTP or HTTPS protocols. \n When using the Hostname value to select between same-Port, same-Protocol Listeners, the Hostname value must be different on each Listener for the Listener to be distinct. \n When the Listeners are distinct based on Hostname, inbound request hostnames MUST match from the most specific to least specific Hostname values to choose the correct Listener and its associated set of Routes. \n Exact matches must be processed before wildcard matches, and wildcard matches must be processed before fallback (empty Hostname value) matches. For example, `\"foo.example.com\"` takes precedence over `\"*.example.com\"`, and `\"*.example.com\"` takes precedence over `\"\"`. \n Additionally, if there are multiple wildcard entries, more specific wildcard entries must be processed before less specific wildcard entries. For example, `\"*.foo.example.com\"` takes precedence over `\"*.example.com\"`. The precise definition here is that the higher the number of dots in the hostname to the right of the wildcard character, the higher the precedence. \n The wildcard character will match any number of characters _and dots_ to the left, however, so `\"*.example.com\"` will match both `\"foo.bar.example.com\"` _and_ `\"bar.example.com\"`. \n If a set of Listeners contains Listeners that are not distinct, then those Listeners are Conflicted, and the implementation MUST set the \"Conflicted\" condition in the Listener Status to \"True\". \n Implementations MAY choose to accept a Gateway with some Conflicted Listeners only if they only accept the partial Listener set that contains no Conflicted Listeners. To put this another way, implementations may accept a partial Listener set only if they throw out *all* the conflicting Listeners. No picking one of the conflicting listeners as the winner. This also means that the Gateway must have at least one non-conflicting Listener in this case, otherwise it violates the requirement that at least one Listener must be present. \n The implementation MUST set a \"ListenersNotValid\" condition on the Gateway Status when the Gateway contains Conflicted Listeners whether or not they accept the Gateway. That Condition SHOULD clearly indicate in the Message which Listeners are conflicted, and which are Accepted. Additionally, the Listener status for those listeners SHOULD indicate which Listeners are conflicted and not Accepted. \n A Gateway's Listeners are considered \"compatible\" if: \n 1. They are distinct. 2. The implementation can serve them in compliance with the Addresses requirement that all Listeners are available on all assigned addresses. \n Compatible combinations in Extended support are expected to vary across implementations. A combination that is compatible for one implementation may not be compatible for another. \n For example, an implementation that cannot serve both TCP and UDP listeners on the same address, or cannot mix HTTPS and generic TLS listens on the same port would not consider those cases compatible, even though they are distinct. \n Note that requests SHOULD match at most one Listener. For example, if Listeners are defined for \"foo.example.com\" and \"*.example.com\", a request to \"foo.example.com\" SHOULD only be routed using routes attached to the \"foo.example.com\" Listener (and not the \"*.example.com\" Listener). This concept is known as \"Listener Isolation\". Implementations that do not support Listener Isolation MUST clearly document this. \n Implementations MAY merge separate Gateways onto a single set of Addresses if all Listeners across all Gateways are compatible. \n Support: Core"
                  items:
                    description: Listener embodies the concept of a logical endpoint where a Gateway accepts network connections.
                    properties:
                      allowedRoutes:
                        default:
                          namespaces:
                            from: Same
                        description: "AllowedRoutes defines the types of routes that MAY be attached to a Listener and the trusted namespaces where those Route resources MAY be present. \n Although a client request may match multiple route rules, only one rule may ultimately receive the request. Matching precedence MUST be determined in order of the following criteria: \n * The most specific match as defined by the Route type. * The oldest Route based on creation timestamp. For example, a Route with a creation timestamp of \"2020-09-08 01:02:03\" is given precedence over a Route with a creation timestamp of \"2020-09-08 01:02:04\". * If everything else is equivalent, the Route appearing first in alphabetical order (namespace/name) should be given precedence. For example, foo/bar is given precedence over foo/baz. \n All valid rules within a Route attached to this Listener should be implemented. Invalid Route rules can be ignored (sometimes that will mean the full Route). If a Route rule transitions from valid to invalid, support for that Route rule should be dropped to ensure consistency. For example, even if a filter specified by a Route rule is invalid, the rest of the rules within that Route should still be supported. \n Support: Core"
                        properties:
                          kinds:
                            description: "Kinds specifies the groups and kinds of Routes that are allowed to bind to this Gateway Listener. When unspecified or empty, the kinds of Routes selected are determined using the Listener protocol. \n A RouteGroupKind MUST correspond to kinds of Routes that are compatible with the application protocol specified in the Listener's Protocol field. If an implementation does not support or recognize this resource type, it MUST set the \"ResolvedRefs\" condition to False for this Listener with the \"InvalidRouteKinds\" reason. \n Support: Core"
                            items:
                              description: RouteGroupKind indicates the group and kind of a Route resource.
                              properties:
                                group:
                                  default: gateway.networking.k8s.io
                                  description: Group is the group of the Route.
                                  maxLength: 253
                                  pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                                  type: string
                                kind:
                                  description: Kind is the kind of the Route.
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                                  type: string
                              required:
                                - kind
                              type: object
                            maxItems: 8
                            type: array
                          namespaces:
                            default:
                              from: Same
                            description: "Namespaces indicates namespaces from which Routes may be attached to this Listener. This is restricted to the namespace of this Gateway by default. \n Support: Core"
                            properties:
                              from:
                                default: Same
                                description: "From indicates where Routes will be selected for this Gateway. Possible values are: \n * All: Routes in all namespaces may be used by this Gateway. * Selector: Routes in namespaces selected by the selector may be used by this Gateway. * Same: Only Routes in the same namespace may be used by this Gateway. \n Support: Core"
                                enum:
                                  - All
                                  - Selector
                                  - Same
                                type: string
                              selector:
                                description: "Selector must be specified when From is set to \"Selector\". In that case, only Routes in Namespaces matching this Selector will be selected by this Gateway. This field is ignored for other values of \"From\". \n Support: Core"
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label selector requirements. The requirements are ANDed.
                                    items:
                                      description: A label selector requirement is a selector that contains values, a key, and an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's relationship to a set of values. Valid operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. This array is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                        - key
                                        - operator
                                      type: object
                                    type: array
                                  matchLabels:
                                    additionalProperties:
                                      type: string
                                    description: matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.
                                    type: object
                                type: object
                                x-kubernetes-map-type: atomic
                            type: object
                        type: object
                      hostname:
                        description: "Hostname specifies the virtual hostname to match for protocol types that define this concept. When unspecified, all hostnames are matched. This field is ignored for protocols that don't require hostname based matching. \n Implementations MUST apply Hostname matching appropriately for each of the following protocols: \n * TLS: The Listener Hostname MUST match the SNI. * HTTP: The Listener Hostname MUST match the Host header of the request. * HTTPS: The Listener Hostname SHOULD match at both the TLS and HTTP protocol layers as described above. If an implementation does not ensure that both the SNI and Host header match the Listener hostname, it MUST clearly document that. \n For HTTPRoute and TLSRoute resources, there is an interaction with the `spec.hostnames` array. When both listener and route specify hostnames, there MUST be an intersection between the values for a Route to be accepted. For more information, refer to the Route specific Hostnames documentation. \n Hostnames that are prefixed with a wildcard label (`*.`) are interpreted as a suffix match. That means that a match for `*.example.com` would match both `test.example.com`, and `foo.test.example.com`, but not `example.com`. \n Support: Core"
                        maxLength: 253
                        minLength: 1
                        pattern: ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      name:
                        description: "Name is the name of the Listener. This name MUST be unique within a Gateway. \n Support: Core"
                        maxLength: 253
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      port:
                        description: "Port is the network port. Multiple listeners may use the same port, subject to the Listener compatibility rules. \n Support: Core"
                        format: int32
                        maximum: 65535
                        minimum: 1
                        type: integer
                      protocol:
                        description: "Protocol specifies the network protocol this listener expects to receive. \n Support: Core"
                        maxLength: 255
                        minLength: 1
                        pattern: ^[a-zA-Z0-9]([-a-zSA-Z0-9]*[a-zA-Z0-9])?$|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9]+$
                        type: string
                      tls:
                        description: "TLS is the TLS configuration for the Listener. This field is required if the Protocol field is \"HTTPS\" or \"TLS\". It is invalid to set this field if the Protocol field is \"HTTP\", \"TCP\", or \"UDP\". \n The association of SNIs to Certificate defined in GatewayTLSConfig is defined based on the Hostname field for this listener. \n The GatewayClass MUST use the longest matching SNI out of all available certificates for any TLS handshake. \n Support: Core"
                        properties:
                          certificateRefs:
                            description: "CertificateRefs contains a series of references to Kubernetes objects that contains TLS certificates and private keys. These certificates are used to establish a TLS handshake for requests that match the hostname of the associated listener. \n A single CertificateRef to a Kubernetes Secret has \"Core\" support. Implementations MAY choose to support attaching multiple certificates to a Listener, but this behavior is implementation-specific. \n References to a resource in different namespace are invalid UNLESS there is a ReferenceGrant in the target namespace that allows the certificate to be attached. If a ReferenceGrant does not allow this reference, the \"ResolvedRefs\" condition MUST be set to False for this listener with the \"RefNotPermitted\" reason. \n This field is required to have at least one element when the mode is set to \"Terminate\" (default) and is optional otherwise. \n CertificateRefs can reference to standard Kubernetes resources, i.e. Secret, or implementation-specific custom resources. \n Support: Core - A single reference to a Kubernetes Secret of type kubernetes.io/tls \n Support: Implementation-specific (More than one reference or other resource types)"
                            items:
                              description: "SecretObjectReference identifies an API object including its namespace, defaulting to Secret. \n The API object must be valid in the cluster; the Group and Kind must be registered in the cluster for this reference to be valid. \n References to objects with invalid Group and Kind are not valid, and must be rejected by the implementation, with appropriate Conditions set on the containing object."
                              properties:
                                group:
                                  default: ""
                                  description: Group is the group of the referent. For example, "gateway.networking.k8s.io". When unspecified or empty string, core API group is inferred.
                                  maxLength: 253
                                  pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                                  type: string
                                kind:
                                  default: Secret
                                  description: Kind is kind of the referent. For example "Secret".
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                                  type: string
                                name:
                                  description: Name is the name of the referent.
                                  maxLength: 253
                                  minLength: 1
                                  type: string
                                namespace:
                                  description: "Namespace is the namespace of the referenced object. When unspecified, the local namespace is inferred. \n Note that when a namespace different than the local namespace is specified, a ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details. \n Support: Core"
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                                  type: string
                              required:
                                - name
                              type: object
                            maxItems: 64
                            type: array
                          mode:
                            default: Terminate
                            description: "Mode defines the TLS behavior for the TLS session initiated by the client. There are two possible modes: \n - Terminate: The TLS session between the downstream client and the Gateway is terminated at the Gateway. This mode requires certificateRefs to be set and contain at least one element. - Passthrough: The TLS session is NOT terminated by the Gateway. This implies that the Gateway can't decipher the TLS stream except for the ClientHello message of the TLS protocol. CertificateRefs field is ignored in this mode. \n Support: Core"
                            enum:
                              - Terminate
                              - Passthrough
                            type: string
                          options:
                            additionalProperties:
                              description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                              maxLength: 4096
                              minLength: 0
                              type: string
                            description: "Options are a list of key/value pairs to enable extended TLS configuration for each implementation. For example, configuring the minimum TLS version or supported cipher suites. \n A set of common keys MAY be defined by the API in the future. To avoid any ambiguity, implementation-specific definitions MUST use domain-prefixed names, such as `example.com/my-custom-option`. Un-prefixed names are reserved for key names defined by Gateway API. \n Support: Implementation-specific"
                            maxProperties: 16
                            type: object
                        type: object
                        x-kubernetes-validations:
                          - message: certificateRefs must be specified when TLSModeType is Terminate
                            rule: "self.mode == 'Terminate' ? size(self.certificateRefs) > 0 : true"
                    required:
                      - name
                      - port
                      - protocol
                    type: object
                  maxItems: 64
                  minItems: 1
                  type: array
                  x-kubernetes-list-map-keys:
                    - name
                  x-kubernetes-list-type: map
                  x-kubernetes-validations:
                    - message: tls must be specified for protocols ['HTTPS', 'TLS']
                      rule: "self.all(l, l.protocol in ['HTTPS', 'TLS'] ? has(l.tls) : true)"
                    - message: tls must not be specified for protocols ['HTTP', 'TCP', 'UDP']
                      rule: "self.all(l, l.protocol in ['HTTP', 'TCP', 'UDP'] ? !has(l.tls) : true)"
                    - message: hostname must not be specified for protocols ['TCP', 'UDP']
                      rule: "self.all(l, l.protocol in ['TCP', 'UDP']  ? (!has(l.hostname) || l.hostname == '') : true)"
                    - message: Listener name must be unique within the Gateway
                      rule: self.all(l1, self.exists_one(l2, l1.name == l2.name))
                    - message: Combination of port, protocol and hostname must be unique for each listener
                      rule: "self.all(l1, self.exists_one(l2, l1.port == l2.port && l1.protocol == l2.protocol && (has(l1.hostname) && has(l2.hostname) ? l1.hostname == l2.hostname : !has(l1.hostname) && !has(l2.hostname))))"
              required:
                - gatewayClassName
                - listeners
              type: object
            status:
              default:
                conditions:
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Pending
                    status: Unknown
                    type: Accepted
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Pending
                    status: Unknown
                    type: Programmed
              description: Status defines the current state of Gateway.
              properties:
                addresses:
                  description: "Addresses lists the network addresses that have been bound to the Gateway. \n This list may differ from the addresses provided in the spec under some conditions: \n * no addresses are specified, all addresses are dynamically assigned * a combination of specified and dynamic addresses are assigned * a specified address was unusable (e.g. already in use) \n "
                  items:
                    description: GatewayStatusAddress describes a network address that is bound to a Gateway.
                    oneOf:
                      - properties:
                          type:
                            enum:
                              - IPAddress
                          value:
                            anyOf:
                              - format: ipv4
                              - format: ipv6
                      - properties:
                          type:
                            not:
                              enum:
                                - IPAddress
                    properties:
                      type:
                        default: IPAddress
                        description: Type of the address.
                        maxLength: 253
                        minLength: 1
                        pattern: ^Hostname|IPAddress|NamedAddress|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                        type: string
                      value:
                        description: "Value of the address. The validity of the values will depend on the type and support by the controller. \n Examples: `1.2.3.4`, `128::1`, `my-ip-address`."
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - value
                    type: object
                    x-kubernetes-validations:
                      - message: Hostname value must only contain valid characters (matching ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$)
                        rule: 'self.type == ''Hostname'' ? self.value.matches(r"""^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"""): true'
                  maxItems: 16
                  type: array
                conditions:
                  default:
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Accepted
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Programmed
                  description: "Conditions describe the current conditions of the Gateway. \n Implementations should prefer to express Gateway conditions using the `GatewayConditionType` and `GatewayConditionReason` constants so that operators and tools can converge on a common vocabulary to describe Gateway state. \n Known condition types are: \n * \"Accepted\" * \"Programmed\" * \"Ready\""
                  items:
                    description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                    properties:
                      lastTransitionTime:
                        description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                        format: date-time
                        type: string
                      message:
                        description: message is a human readable message indicating details about the transition. This may be an empty string.
                        maxLength: 32768
                        type: string
                      observedGeneration:
                        description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                        format: int64
                        minimum: 0
                        type: integer
                      reason:
                        description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                        maxLength: 1024
                        minLength: 1
                        pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                        type: string
                      status:
                        description: status of the condition, one of True, False, Unknown.
                        enum:
                          - "True"
                          - "False"
                          - Unknown
                        type: string
                      type:
                        description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                        maxLength: 316
                        pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                        type: string
                    required:
                      - lastTransitionTime
                      - message
                      - reason
                      - status
                      - type
                    type: object
                  maxItems: 8
                  type: array
                  x-kubernetes-list-map-keys:
                    - type
                  x-kubernetes-list-type: map
                listeners:
                  description: Listeners provide status for each unique listener port defined in the Spec.
                  items:
                    description: ListenerStatus is the status associated with a Listener.
                    properties:
                      attachedRoutes:
                        description: "AttachedRoutes represents the total number of Routes that have been successfully attached to this Listener. \n Successful attachment of a Route to a Listener is based solely on the combination of the AllowedRoutes field on the corresponding Listener and the Route's ParentRefs field. A Route is successfully attached to a Listener when it is selected by the Listener's AllowedRoutes field AND the Route has a valid ParentRef selecting the whole Gateway resource or a specific Listener as a parent resource (more detail on attachment semantics can be found in the documentation on the various Route kinds ParentRefs fields). Listener or Route status does not impact successful attachment, i.e. the AttachedRoutes field count MUST be set for Listeners with condition Accepted: false and MUST count successfully attached Routes that may themselves have Accepted: false conditions. \n Uses for this field include troubleshooting Route attachment and measuring blast radius/impact of changes to a Listener."
                        format: int32
                        type: integer
                      conditions:
                        description: Conditions describe the current condition of this listener.
                        items:
                          description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                          properties:
                            lastTransitionTime:
                              description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                              format: date-time
                              type: string
                            message:
                              description: message is a human readable message indicating details about the transition. This may be an empty string.
                              maxLength: 32768
                              type: string
                            observedGeneration:
                              description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                              format: int64
                              minimum: 0
                              type: integer
                            reason:
                              description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                              maxLength: 1024
                              minLength: 1
                              pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                              type: string
                            status:
                              description: status of the condition, one of True, False, Unknown.
                              enum:
                                - "True"
                                - "False"
                                - Unknown
                              type: string
                            type:
                              description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                              maxLength: 316
                              pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                              type: string
                          required:
                            - lastTransitionTime
                            - message
                            - reason
                            - status
                            - type
                          type: object
                        maxItems: 8
                        type: array
                        x-kubernetes-list-map-keys:
                          - type
                        x-kubernetes-list-type: map
                      name:
                        description: Name is the name of the Listener that this status corresponds to.
                        maxLength: 253
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      supportedKinds:
                        description: "SupportedKinds is the list indicating the Kinds supported by this listener. This MUST represent the kinds an implementation supports for that Listener configuration. \n If kinds are specified in Spec that are not supported, they MUST NOT appear in this list and an implementation MUST set the \"ResolvedRefs\" condition to \"False\" with the \"InvalidRouteKinds\" reason. If both valid and invalid Route kinds are specified, the implementation MUST reference the valid Route kinds that have been specified."
                        items:
                          description: RouteGroupKind indicates the group and kind of a Route resource.
                          properties:
                            group:
                              default: gateway.networking.k8s.io
                              description: Group is the group of the Route.
                              maxLength: 253
                              pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                              type: string
                            kind:
                              description: Kind is the kind of the Route.
                              maxLength: 63
                              minLength: 1
                              pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                              type: string
                          required:
                            - kind
                          type: object
                        maxItems: 8
                        type: array
                    required:
                      - attachedRoutes
                      - conditions
                      - name
                      - supportedKinds
                    type: object
                  maxItems: 64
                  type: array
                  x-kubernetes-list-map-keys:
                    - name
                  x-kubernetes-list-type: map
              type: object
          required:
            - spec
          type: object
      served: true
      storage: false
      subresources:
        status: {}
    - additionalPrinterColumns:
        - jsonPath: .spec.gatewayClassName
          name: Class
          type: string
        - jsonPath: .status.addresses[*].value
          name: Address
          type: string
        - jsonPath: .status.conditions[?(@.type=="Programmed")].status
          name: Programmed
          type: string
        - jsonPath: .metadata.creationTimestamp
          name: Age
          type: date
      name: v1beta1
      schema:
        openAPIV3Schema:
          description: Gateway represents an instance of a service-traffic handling infrastructure by binding Listeners to a set of IP addresses.
          properties:
            apiVersion:
              description: "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
              type: string
            kind:
              description: "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
              type: string
            metadata:
              type: object
            spec:
              description: Spec defines the desired state of Gateway.
              properties:
                addresses:
                  description: "Addresses requested for this Gateway. This is optional and behavior can depend on the implementation. If a value is set in the spec and the requested address is invalid or unavailable, the implementation MUST indicate this in the associated entry in GatewayStatus.Addresses. \n The Addresses field represents a request for the address(es) on the \"outside of the Gateway\", that traffic bound for this Gateway will use. This could be the IP address or hostname of an external load balancer or other networking infrastructure, or some other address that traffic will be sent to. \n If no Addresses are specified, the implementation MAY schedule the Gateway in an implementation-specific manner, assigning an appropriate set of Addresses. \n The implementation MUST bind all Listeners to every GatewayAddress that it assigns to the Gateway and add a corresponding entry in GatewayStatus.Addresses. \n Support: Extended \n "
                  items:
                    description: GatewayAddress describes an address that can be bound to a Gateway.
                    oneOf:
                      - properties:
                          type:
                            enum:
                              - IPAddress
                          value:
                            anyOf:
                              - format: ipv4
                              - format: ipv6
                      - properties:
                          type:
                            not:
                              enum:
                                - IPAddress
                    properties:
                      type:
                        default: IPAddress
                        description: Type of the address.
                        maxLength: 253
                        minLength: 1
                        pattern: ^Hostname|IPAddress|NamedAddress|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                        type: string
                      value:
                        description: "Value of the address. The validity of the values will depend on the type and support by the controller. \n Examples: `1.2.3.4`, `128::1`, `my-ip-address`."
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - value
                    type: object
                    x-kubernetes-validations:
                      - message: Hostname value must only contain valid characters (matching ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$)
                        rule: 'self.type == ''Hostname'' ? self.value.matches(r"""^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"""): true'
                  maxItems: 16
                  type: array
                  x-kubernetes-validations:
                    - message: IPAddress values must be unique
                      rule: "self.all(a1, a1.type == 'IPAddress' ? self.exists_one(a2, a2.type == a1.type && a2.value == a1.value) : true )"
                    - message: Hostname values must be unique
                      rule: "self.all(a1, a1.type == 'Hostname' ? self.exists_one(a2, a2.type == a1.type && a2.value == a1.value) : true )"
                gatewayClassName:
                  description: GatewayClassName used for this Gateway. This is the name of a GatewayClass resource.
                  maxLength: 253
                  minLength: 1
                  type: string
                infrastructure:
                  description: "Infrastructure defines infrastructure level attributes about this Gateway instance. \n Support: Core \n "
                  properties:
                    annotations:
                      additionalProperties:
                        description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                        maxLength: 4096
                        minLength: 0
                        type: string
                      description: "Annotations that SHOULD be applied to any resources created in response to this Gateway. \n For implementations creating other Kubernetes objects, this should be the `metadata.annotations` field on resources. For other implementations, this refers to any relevant (implementation specific) \"annotations\" concepts. \n An implementation may chose to add additional implementation-specific annotations as they see fit. \n Support: Extended"
                      maxProperties: 8
                      type: object
                    labels:
                      additionalProperties:
                        description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                        maxLength: 4096
                        minLength: 0
                        type: string
                      description: "Labels that SHOULD be applied to any resources created in response to this Gateway. \n For implementations creating other Kubernetes objects, this should be the `metadata.labels` field on resources. For other implementations, this refers to any relevant (implementation specific) \"labels\" concepts. \n An implementation may chose to add additional implementation-specific labels as they see fit. \n Support: Extended"
                      maxProperties: 8
                      type: object
                  type: object
                listeners:
                  description: "Listeners associated with this Gateway. Listeners define logical endpoints that are bound on this Gateway's addresses. At least one Listener MUST be specified. \n Each Listener in a set of Listeners (for example, in a single Gateway) MUST be _distinct_, in that a traffic flow MUST be able to be assigned to exactly one listener. (This section uses \"set of Listeners\" rather than \"Listeners in a single Gateway\" because implementations MAY merge configuration from multiple Gateways onto a single data plane, and these rules _also_ apply in that case). \n Practically, this means that each listener in a set MUST have a unique combination of Port, Protocol, and, if supported by the protocol, Hostname. \n Some combinations of port, protocol, and TLS settings are considered Core support and MUST be supported by implementations based on their targeted conformance profile: \n HTTP Profile \n 1. HTTPRoute, Port: 80, Protocol: HTTP 2. HTTPRoute, Port: 443, Protocol: HTTPS, TLS Mode: Terminate, TLS keypair provided \n TLS Profile \n 1. TLSRoute, Port: 443, Protocol: TLS, TLS Mode: Passthrough \n \"Distinct\" Listeners have the following property: \n The implementation can match inbound requests to a single distinct Listener. When multiple Listeners share values for fields (for example, two Listeners with the same Port value), the implementation can match requests to only one of the Listeners using other Listener fields. \n For example, the following Listener scenarios are distinct: \n 1. Multiple Listeners with the same Port that all use the \"HTTP\" Protocol that all have unique Hostname values. 2. Multiple Listeners with the same Port that use either the \"HTTPS\" or \"TLS\" Protocol that all have unique Hostname values. 3. A mixture of \"TCP\" and \"UDP\" Protocol Listeners, where no Listener with the same Protocol has the same Port value. \n Some fields in the Listener struct have possible values that affect whether the Listener is distinct. Hostname is particularly relevant for HTTP or HTTPS protocols. \n When using the Hostname value to select between same-Port, same-Protocol Listeners, the Hostname value must be different on each Listener for the Listener to be distinct. \n When the Listeners are distinct based on Hostname, inbound request hostnames MUST match from the most specific to least specific Hostname values to choose the correct Listener and its associated set of Routes. \n Exact matches must be processed before wildcard matches, and wildcard matches must be processed before fallback (empty Hostname value) matches. For example, `\"foo.example.com\"` takes precedence over `\"*.example.com\"`, and `\"*.example.com\"` takes precedence over `\"\"`. \n Additionally, if there are multiple wildcard entries, more specific wildcard entries must be processed before less specific wildcard entries. For example, `\"*.foo.example.com\"` takes precedence over `\"*.example.com\"`. The precise definition here is that the higher the number of dots in the hostname to the right of the wildcard character, the higher the precedence. \n The wildcard character will match any number of characters _and dots_ to the left, however, so `\"*.example.com\"` will match both `\"foo.bar.example.com\"` _and_ `\"bar.example.com\"`. \n If a set of Listeners contains Listeners that are not distinct, then those Listeners are Conflicted, and the implementation MUST set the \"Conflicted\" condition in the Listener Status to \"True\". \n Implementations MAY choose to accept a Gateway with some Conflicted Listeners only if they only accept the partial Listener set that contains no Conflicted Listeners. To put this another way, implementations may accept a partial Listener set only if they throw out *all* the conflicting Listeners. No picking one of the conflicting listeners as the winner. This also means that the Gateway must have at least one non-conflicting Listener in this case, otherwise it violates the requirement that at least one Listener must be present. \n The implementation MUST set a \"ListenersNotValid\" condition on the Gateway Status when the Gateway contains Conflicted Listeners whether or not they accept the Gateway. That Condition SHOULD clearly indicate in the Message which Listeners are conflicted, and which are Accepted. Additionally, the Listener status for those listeners SHOULD indicate which Listeners are conflicted and not Accepted. \n A Gateway's Listeners are considered \"compatible\" if: \n 1. They are distinct. 2. The implementation can serve them in compliance with the Addresses requirement that all Listeners are available on all assigned addresses. \n Compatible combinations in Extended support are expected to vary across implementations. A combination that is compatible for one implementation may not be compatible for another. \n For example, an implementation that cannot serve both TCP and UDP listeners on the same address, or cannot mix HTTPS and generic TLS listens on the same port would not consider those cases compatible, even though they are distinct. \n Note that requests SHOULD match at most one Listener. For example, if Listeners are defined for \"foo.example.com\" and \"*.example.com\", a request to \"foo.example.com\" SHOULD only be routed using routes attached to the \"foo.example.com\" Listener (and not the \"*.example.com\" Listener). This concept is known as \"Listener Isolation\". Implementations that do not support Listener Isolation MUST clearly document this. \n Implementations MAY merge separate Gateways onto a single set of Addresses if all Listeners across all Gateways are compatible. \n Support: Core"
                  items:
                    description: Listener embodies the concept of a logical endpoint where a Gateway accepts network connections.
                    properties:
                      allowedRoutes:
                        default:
                          namespaces:
                            from: Same
                        description: "AllowedRoutes defines the types of routes that MAY be attached to a Listener and the trusted namespaces where those Route resources MAY be present. \n Although a client request may match multiple route rules, only one rule may ultimately receive the request. Matching precedence MUST be determined in order of the following criteria: \n * The most specific match as defined by the Route type. * The oldest Route based on creation timestamp. For example, a Route with a creation timestamp of \"2020-09-08 01:02:03\" is given precedence over a Route with a creation timestamp of \"2020-09-08 01:02:04\". * If everything else is equivalent, the Route appearing first in alphabetical order (namespace/name) should be given precedence. For example, foo/bar is given precedence over foo/baz. \n All valid rules within a Route attached to this Listener should be implemented. Invalid Route rules can be ignored (sometimes that will mean the full Route). If a Route rule transitions from valid to invalid, support for that Route rule should be dropped to ensure consistency. For example, even if a filter specified by a Route rule is invalid, the rest of the rules within that Route should still be supported. \n Support: Core"
                        properties:
                          kinds:
                            description: "Kinds specifies the groups and kinds of Routes that are allowed to bind to this Gateway Listener. When unspecified or empty, the kinds of Routes selected are determined using the Listener protocol. \n A RouteGroupKind MUST correspond to kinds of Routes that are compatible with the application protocol specified in the Listener's Protocol field. If an implementation does not support or recognize this resource type, it MUST set the \"ResolvedRefs\" condition to False for this Listener with the \"InvalidRouteKinds\" reason. \n Support: Core"
                            items:
                              description: RouteGroupKind indicates the group and kind of a Route resource.
                              properties:
                                group:
                                  default: gateway.networking.k8s.io
                                  description: Group is the group of the Route.
                                  maxLength: 253
                                  pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                                  type: string
                                kind:
                                  description: Kind is the kind of the Route.
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                                  type: string
                              required:
                                - kind
                              type: object
                            maxItems: 8
                            type: array
                          namespaces:
                            default:
                              from: Same
                            description: "Namespaces indicates namespaces from which Routes may be attached to this Listener. This is restricted to the namespace of this Gateway by default. \n Support: Core"
                            properties:
                              from:
                                default: Same
                                description: "From indicates where Routes will be selected for this Gateway. Possible values are: \n * All: Routes in all namespaces may be used by this Gateway. * Selector: Routes in namespaces selected by the selector may be used by this Gateway. * Same: Only Routes in the same namespace may be used by this Gateway. \n Support: Core"
                                enum:
                                  - All
                                  - Selector
                                  - Same
                                type: string
                              selector:
                                description: "Selector must be specified when From is set to \"Selector\". In that case, only Routes in Namespaces matching this Selector will be selected by this Gateway. This field is ignored for other values of \"From\". \n Support: Core"
                                properties:
                                  matchExpressions:
                                    description: matchExpressions is a list of label selector requirements. The requirements are ANDed.
                                    items:
                                      description: A label selector requirement is a selector that contains values, a key, and an operator that relates the key and values.
                                      properties:
                                        key:
                                          description: key is the label key that the selector applies to.
                                          type: string
                                        operator:
                                          description: operator represents a key's relationship to a set of values. Valid operators are In, NotIn, Exists and DoesNotExist.
                                          type: string
                                        values:
                                          description: values is an array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. This array is replaced during a strategic merge patch.
                                          items:
                                            type: string
                                          type: array
                                      required:
                                        - key
                                        - operator
                                      type: object
                                    type: array
                                  matchLabels:
                                    additionalProperties:
                                      type: string
                                    description: matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value". The requirements are ANDed.
                                    type: object
                                type: object
                                x-kubernetes-map-type: atomic
                            type: object
                        type: object
                      hostname:
                        description: "Hostname specifies the virtual hostname to match for protocol types that define this concept. When unspecified, all hostnames are matched. This field is ignored for protocols that don't require hostname based matching. \n Implementations MUST apply Hostname matching appropriately for each of the following protocols: \n * TLS: The Listener Hostname MUST match the SNI. * HTTP: The Listener Hostname MUST match the Host header of the request. * HTTPS: The Listener Hostname SHOULD match at both the TLS and HTTP protocol layers as described above. If an implementation does not ensure that both the SNI and Host header match the Listener hostname, it MUST clearly document that. \n For HTTPRoute and TLSRoute resources, there is an interaction with the `spec.hostnames` array. When both listener and route specify hostnames, there MUST be an intersection between the values for a Route to be accepted. For more information, refer to the Route specific Hostnames documentation. \n Hostnames that are prefixed with a wildcard label (`*.`) are interpreted as a suffix match. That means that a match for `*.example.com` would match both `test.example.com`, and `foo.test.example.com`, but not `example.com`. \n Support: Core"
                        maxLength: 253
                        minLength: 1
                        pattern: ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      name:
                        description: "Name is the name of the Listener. This name MUST be unique within a Gateway. \n Support: Core"
                        maxLength: 253
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      port:
                        description: "Port is the network port. Multiple listeners may use the same port, subject to the Listener compatibility rules. \n Support: Core"
                        format: int32
                        maximum: 65535
                        minimum: 1
                        type: integer
                      protocol:
                        description: "Protocol specifies the network protocol this listener expects to receive. \n Support: Core"
                        maxLength: 255
                        minLength: 1
                        pattern: ^[a-zA-Z0-9]([-a-zSA-Z0-9]*[a-zA-Z0-9])?$|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9]+$
                        type: string
                      tls:
                        description: "TLS is the TLS configuration for the Listener. This field is required if the Protocol field is \"HTTPS\" or \"TLS\". It is invalid to set this field if the Protocol field is \"HTTP\", \"TCP\", or \"UDP\". \n The association of SNIs to Certificate defined in GatewayTLSConfig is defined based on the Hostname field for this listener. \n The GatewayClass MUST use the longest matching SNI out of all available certificates for any TLS handshake. \n Support: Core"
                        properties:
                          certificateRefs:
                            description: "CertificateRefs contains a series of references to Kubernetes objects that contains TLS certificates and private keys. These certificates are used to establish a TLS handshake for requests that match the hostname of the associated listener. \n A single CertificateRef to a Kubernetes Secret has \"Core\" support. Implementations MAY choose to support attaching multiple certificates to a Listener, but this behavior is implementation-specific. \n References to a resource in different namespace are invalid UNLESS there is a ReferenceGrant in the target namespace that allows the certificate to be attached. If a ReferenceGrant does not allow this reference, the \"ResolvedRefs\" condition MUST be set to False for this listener with the \"RefNotPermitted\" reason. \n This field is required to have at least one element when the mode is set to \"Terminate\" (default) and is optional otherwise. \n CertificateRefs can reference to standard Kubernetes resources, i.e. Secret, or implementation-specific custom resources. \n Support: Core - A single reference to a Kubernetes Secret of type kubernetes.io/tls \n Support: Implementation-specific (More than one reference or other resource types)"
                            items:
                              description: "SecretObjectReference identifies an API object including its namespace, defaulting to Secret. \n The API object must be valid in the cluster; the Group and Kind must be registered in the cluster for this reference to be valid. \n References to objects with invalid Group and Kind are not valid, and must be rejected by the implementation, with appropriate Conditions set on the containing object."
                              properties:
                                group:
                                  default: ""
                                  description: Group is the group of the referent. For example, "gateway.networking.k8s.io". When unspecified or empty string, core API group is inferred.
                                  maxLength: 253
                                  pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                                  type: string
                                kind:
                                  default: Secret
                                  description: Kind is kind of the referent. For example "Secret".
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                                  type: string
                                name:
                                  description: Name is the name of the referent.
                                  maxLength: 253
                                  minLength: 1
                                  type: string
                                namespace:
                                  description: "Namespace is the namespace of the referenced object. When unspecified, the local namespace is inferred. \n Note that when a namespace different than the local namespace is specified, a ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details. \n Support: Core"
                                  maxLength: 63
                                  minLength: 1
                                  pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$
                                  type: string
                              required:
                                - name
                              type: object
                            maxItems: 64
                            type: array
                          mode:
                            default: Terminate
                            description: "Mode defines the TLS behavior for the TLS session initiated by the client. There are two possible modes: \n - Terminate: The TLS session between the downstream client and the Gateway is terminated at the Gateway. This mode requires certificateRefs to be set and contain at least one element. - Passthrough: The TLS session is NOT terminated by the Gateway. This implies that the Gateway can't decipher the TLS stream except for the ClientHello message of the TLS protocol. CertificateRefs field is ignored in this mode. \n Support: Core"
                            enum:
                              - Terminate
                              - Passthrough
                            type: string
                          options:
                            additionalProperties:
                              description: AnnotationValue is the value of an annotation in Gateway API. This is used for validation of maps such as TLS options. This roughly matches Kubernetes annotation validation, although the length validation in that case is based on the entire size of the annotations struct.
                              maxLength: 4096
                              minLength: 0
                              type: string
                            description: "Options are a list of key/value pairs to enable extended TLS configuration for each implementation. For example, configuring the minimum TLS version or supported cipher suites. \n A set of common keys MAY be defined by the API in the future. To avoid any ambiguity, implementation-specific definitions MUST use domain-prefixed names, such as `example.com/my-custom-option`. Un-prefixed names are reserved for key names defined by Gateway API. \n Support: Implementation-specific"
                            maxProperties: 16
                            type: object
                        type: object
                        x-kubernetes-validations:
                          - message: certificateRefs must be specified when TLSModeType is Terminate
                            rule: "self.mode == 'Terminate' ? size(self.certificateRefs) > 0 : true"
                    required:
                      - name
                      - port
                      - protocol
                    type: object
                  maxItems: 64
                  minItems: 1
                  type: array
                  x-kubernetes-list-map-keys:
                    - name
                  x-kubernetes-list-type: map
                  x-kubernetes-validations:
                    - message: tls must be specified for protocols ['HTTPS', 'TLS']
                      rule: "self.all(l, l.protocol in ['HTTPS', 'TLS'] ? has(l.tls) : true)"
                    - message: tls must not be specified for protocols ['HTTP', 'TCP', 'UDP']
                      rule: "self.all(l, l.protocol in ['HTTP', 'TCP', 'UDP'] ? !has(l.tls) : true)"
                    - message: hostname must not be specified for protocols ['TCP', 'UDP']
                      rule: "self.all(l, l.protocol in ['TCP', 'UDP']  ? (!has(l.hostname) || l.hostname == '') : true)"
                    - message: Listener name must be unique within the Gateway
                      rule: self.all(l1, self.exists_one(l2, l1.name == l2.name))
                    - message: Combination of port, protocol and hostname must be unique for each listener
                      rule: "self.all(l1, self.exists_one(l2, l1.port == l2.port && l1.protocol == l2.protocol && (has(l1.hostname) && has(l2.hostname) ? l1.hostname == l2.hostname : !has(l1.hostname) && !has(l2.hostname))))"
              required:
                - gatewayClassName
                - listeners
              type: object
            status:
              default:
                conditions:
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Pending
                    status: Unknown
                    type: Accepted
                  - lastTransitionTime: "1970-01-01T00:00:00Z"
                    message: Waiting for controller
                    reason: Pending
                    status: Unknown
                    type: Programmed
              description: Status defines the current state of Gateway.
              properties:
                addresses:
                  description: "Addresses lists the network addresses that have been bound to the Gateway. \n This list may differ from the addresses provided in the spec under some conditions: \n * no addresses are specified, all addresses are dynamically assigned * a combination of specified and dynamic addresses are assigned * a specified address was unusable (e.g. already in use) \n "
                  items:
                    description: GatewayStatusAddress describes a network address that is bound to a Gateway.
                    oneOf:
                      - properties:
                          type:
                            enum:
                              - IPAddress
                          value:
                            anyOf:
                              - format: ipv4
                              - format: ipv6
                      - properties:
                          type:
                            not:
                              enum:
                                - IPAddress
                    properties:
                      type:
                        default: IPAddress
                        description: Type of the address.
                        maxLength: 253
                        minLength: 1
                        pattern: ^Hostname|IPAddress|NamedAddress|[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\/[A-Za-z0-9\/\-._~%!$&'()*+,;=:]+$
                        type: string
                      value:
                        description: "Value of the address. The validity of the values will depend on the type and support by the controller. \n Examples: `1.2.3.4`, `128::1`, `my-ip-address`."
                        maxLength: 253
                        minLength: 1
                        type: string
                    required:
                      - value
                    type: object
                    x-kubernetes-validations:
                      - message: Hostname value must only contain valid characters (matching ^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$)
                        rule: 'self.type == ''Hostname'' ? self.value.matches(r"""^(\*\.)?[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"""): true'
                  maxItems: 16
                  type: array
                conditions:
                  default:
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Accepted
                    - lastTransitionTime: "1970-01-01T00:00:00Z"
                      message: Waiting for controller
                      reason: Pending
                      status: Unknown
                      type: Programmed
                  description: "Conditions describe the current conditions of the Gateway. \n Implementations should prefer to express Gateway conditions using the `GatewayConditionType` and `GatewayConditionReason` constants so that operators and tools can converge on a common vocabulary to describe Gateway state. \n Known condition types are: \n * \"Accepted\" * \"Programmed\" * \"Ready\""
                  items:
                    description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                    properties:
                      lastTransitionTime:
                        description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                        format: date-time
                        type: string
                      message:
                        description: message is a human readable message indicating details about the transition. This may be an empty string.
                        maxLength: 32768
                        type: string
                      observedGeneration:
                        description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                        format: int64
                        minimum: 0
                        type: integer
                      reason:
                        description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                        maxLength: 1024
                        minLength: 1
                        pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                        type: string
                      status:
                        description: status of the condition, one of True, False, Unknown.
                        enum:
                          - "True"
                          - "False"
                          - Unknown
                        type: string
                      type:
                        description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                        maxLength: 316
                        pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                        type: string
                    required:
                      - lastTransitionTime
                      - message
                      - reason
                      - status
                      - type
                    type: object
                  maxItems: 8
                  type: array
                  x-kubernetes-list-map-keys:
                    - type
                  x-kubernetes-list-type: map
                listeners:
                  description: Listeners provide status for each unique listener port defined in the Spec.
                  items:
                    description: ListenerStatus is the status associated with a Listener.
                    properties:
                      attachedRoutes:
                        description: "AttachedRoutes represents the total number of Routes that have been successfully attached to this Listener. \n Successful attachment of a Route to a Listener is based solely on the combination of the AllowedRoutes field on the corresponding Listener and the Route's ParentRefs field. A Route is successfully attached to a Listener when it is selected by the Listener's AllowedRoutes field AND the Route has a valid ParentRef selecting the whole Gateway resource or a specific Listener as a parent resource (more detail on attachment semantics can be found in the documentation on the various Route kinds ParentRefs fields). Listener or Route status does not impact successful attachment, i.e. the AttachedRoutes field count MUST be set for Listeners with condition Accepted: false and MUST count successfully attached Routes that may themselves have Accepted: false conditions. \n Uses for this field include troubleshooting Route attachment and measuring blast radius/impact of changes to a Listener."
                        format: int32
                        type: integer
                      conditions:
                        description: Conditions describe the current condition of this listener.
                        items:
                          description: "Condition contains details for one aspect of the current state of this API Resource. --- This struct is intended for direct use as an array at the field path .status.conditions.  For example, \n type FooStatus struct{ // Represents the observations of a foo's current state. // Known .status.conditions.type are: \"Available\", \"Progressing\", and \"Degraded\" // +patchMergeKey=type // +patchStrategy=merge // +listType=map // +listMapKey=type Conditions []metav1.Condition `json:\"conditions,omitempty\" patchStrategy:\"merge\" patchMergeKey:\"type\" protobuf:\"bytes,1,rep,name=conditions\"` \n // other fields }"
                          properties:
                            lastTransitionTime:
                              description: lastTransitionTime is the last time the condition transitioned from one status to another. This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
                              format: date-time
                              type: string
                            message:
                              description: message is a human readable message indicating details about the transition. This may be an empty string.
                              maxLength: 32768
                              type: string
                            observedGeneration:
                              description: observedGeneration represents the .metadata.generation that the condition was set based upon. For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date with respect to the current state of the instance.
                              format: int64
                              minimum: 0
                              type: integer
                            reason:
                              description: reason contains a programmatic identifier indicating the reason for the condition's last transition. Producers of specific condition types may define expected values and meanings for this field, and whether the values are considered a guaranteed API. The value should be a CamelCase string. This field may not be empty.
                              maxLength: 1024
                              minLength: 1
                              pattern: ^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$
                              type: string
                            status:
                              description: status of the condition, one of True, False, Unknown.
                              enum:
                                - "True"
                                - "False"
                                - Unknown
                              type: string
                            type:
                              description: type of condition in CamelCase or in foo.example.com/CamelCase. --- Many .condition.type values are consistent across resources like Available, but because arbitrary conditions can be useful (see .node.status.conditions), the ability to deconflict is important. The regex it matches is (dns1123SubdomainFmt/)?(qualifiedNameFmt)
                              maxLength: 316
                              pattern: ^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$
                              type: string
                          required:
                            - lastTransitionTime
                            - message
                            - reason
                            - status
                            - type
                          type: object
                        maxItems: 8
                        type: array
                        x-kubernetes-list-map-keys:
                          - type
                        x-kubernetes-list-type: map
                      name:
                        description: Name is the name of the Listener that this status corresponds to.
                        maxLength: 253
                        minLength: 1
                        pattern: ^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                        type: string
                      supportedKinds:
                        description: "SupportedKinds is the list indicating the Kinds supported by this listener. This MUST represent the kinds an implementation supports for that Listener configuration. \n If kinds are specified in Spec that are not supported, they MUST NOT appear in this list and an implementation MUST set the \"ResolvedRefs\" condition to \"False\" with the \"InvalidRouteKinds\" reason. If both valid and invalid Route kinds are specified, the implementation MUST reference the valid Route kinds that have been specified."
                        items:
                          description: RouteGroupKind indicates the group and kind of a Route resource.
                          properties:
                            group:
                              default: gateway.networking.k8s.io
                              description: Group is the group of the Route.
                              maxLength: 253
                              pattern: ^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
                              type: string
                            kind:
                              description: Kind is the kind of the Route.
                              maxLength: 63
                              minLength: 1
                              pattern: ^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$
                              type: string
                          required:
                            - kind
                          type: object
                        maxItems: 8
                        type: array
                    required:
                      - attachedRoutes
                      - conditions
                      - name
                      - supportedKinds
                    type: object
                  maxItems: 64
                  type: array
                  x-kubernetes-list-map-keys:
                    - name
                  x-kubernetes-list-type: map
              type: object
          required:
            - spec
          type: object
      served: true
      storage: true
      subresources:
        status: {}

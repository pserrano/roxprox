package envoy

import (
	"time"

	core "github.com/envoyproxy/go-control-plane/envoy/config/core/v3"
	api "github.com/envoyproxy/go-control-plane/envoy/config/listener/v3"
	extAuthz "github.com/envoyproxy/go-control-plane/envoy/extensions/filters/http/ext_authz/v3"
	"github.com/golang/protobuf/ptypes"
	any "github.com/golang/protobuf/ptypes/any"
)

type AuthzFilter struct{}

func newAuthzFilter() *AuthzFilter {
	return &AuthzFilter{}
}

func (a *AuthzFilter) updateListenersWithAuthzFilter(cache *WorkQueueCache, params ListenerParams) error {
	// update listener
	for listenerKey := range cache.listeners {
		ll := cache.listeners[listenerKey].(*api.Listener)
		for filterchainID := range ll.FilterChains {
			for filterID := range ll.FilterChains[filterchainID].Filters {
				// get manager
				manager, err := getManager((ll.FilterChains[filterchainID].Filters[filterID].ConfigType).(*api.Filter_TypedConfig))
				if err != nil {
					return err
				}

				// get authz config config
				authzConfigEncoded, err := a.getAuthzFilterEncoded(params)
				if err != nil {
					return err
				}

				// update http filter
				updateHTTPFilterWithConfig(&manager.HttpFilters, "envoy.ext_authz", authzConfigEncoded)

				// update manager in cache
				pbst, err := ptypes.MarshalAny(&manager)
				if err != nil {
					return err
				}
				ll.FilterChains[filterchainID].Filters[filterID].ConfigType = &api.Filter_TypedConfig{
					TypedConfig: pbst,
				}

			}

		}

	}

	return nil
}
func (a *AuthzFilter) getAuthzFilterEncoded(params ListenerParams) (*any.Any, error) {
	authzConfig, err := a.getAuthzFilter(params)
	if err != nil {
		return nil, err
	}
	authzConfigEncoded, err := ptypes.MarshalAny(authzConfig)
	if err != nil {
		return nil, err
	}
	return authzConfigEncoded, err
}

func (a *AuthzFilter) getAuthzFilter(params ListenerParams) (*extAuthz.ExtAuthz, error) {
	timeout, err := time.ParseDuration(params.Authz.Timeout)
	if err != nil {
		return nil, err
	}
	return &extAuthz.ExtAuthz{
		FailureModeAllow: params.Authz.FailureModeAllow,
		Services: &extAuthz.ExtAuthz_GrpcService{
			GrpcService: &core.GrpcService{
				Timeout: ptypes.DurationProto(timeout),
				TargetSpecifier: &core.GrpcService_EnvoyGrpc_{
					EnvoyGrpc: &core.GrpcService_EnvoyGrpc{
						ClusterName: params.Name,
					},
				},
			},
		},
	}, nil
}

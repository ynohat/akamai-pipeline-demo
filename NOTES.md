# Pipeline creation

```
akamai pipeline --section a2s-open new-pipeline -c ctr_C-1ED34DY -g grp_125029 -e prp_542877 -p demo.a2s.ninja dev qa prod
```

This created all 3 props (dev, prod, qa.demo.a2s.ninja). Problems:

* CP Code is left null (presumably created by pipeline)
> Switched this to reflect the golden one
* NS info assumes a different storage group for each env
> Because I'm using AK_HOST as the origin base path, I pointed all three at the same SG
* EHN is auto generated for each env
> Used same for all to avoid hassle

Then attempted to save the dev environment

## Save dev env

```
akamai pipeline --section a2s-open save -p demo.a2s.ninja dev
```

Problem: the following behaviour is not yet supported.

```
{
    "name": "autoDomainValidation",
    "options": {
        "autodv": ""
    }
}
```

So I switched to using the classic redirect method.

Problem: got the following validation errors for the mPulse behaviour:

```
    {
        "type": "https://problems.luna.akamaiapis.net/papi/v0/validation/unknown_attribute",
        "errorLocation": {
            "template": "templates/main.json",
            "variables": [],
            "location": "rules/behaviors/6/options/configOverride",
            "value": ""
        },
        "detail": "The behavior '`mPulse`' does not have configOverride."
    },
    {
        "type": "https://problems.luna.akamaiapis.net/papi/v0/validation/unknown_attribute",
        "errorLocation": {
            "template": "templates/main.json",
            "variables": [],
            "location": "rules/behaviors/6/options/requirePci",
            "value": false
        },
        "detail": "The behavior '`mPulse`' does not have requirePci."
    },
    {
        "type": "https://problems.luna.akamaiapis.net/papi/v0/validation/unknown_attribute",
        "errorLocation": {
            "template": "templates/main.json",
            "variables": [],
            "location": "rules/behaviors/6/options/titleOptional",
            "value": ""
        },
        "detail": "The behavior '`mPulse`' does not have titleOptional."
    }
```

So I removed those. The only remaining validation problem was:

```
{
    "type": "https://problems.luna.akamaiapis.net/papi/v0/validation/generic_behavior_issue.netstorage_group_not_available",
    "errorLocation": {
        "template": "templates/main.json",
        "variables": [
            "environments/dev/variables.json"
        ],
        "location": "rules/behaviors/0/options/netStorage",
        "value": {
            "downloadDomainName": "ahogg.download.akamai.com",
            "cpCode": 479318,
            "g2oToken": null
        }
    },
    "detail": "`Origin Server`: The NetStorage Account (<strong>ahogg.download.akamai.com</strong>) cannot be used with this property because the NetStorage Account is not associated with this property's group. Please contact your Account Administrator to resolve this."
}
```

I've never seen this error before. Because activation of the www.demo.a2s.ninja (the golden config) is in progress, maybe this will work after activation.

To fix, I did two things (don't know which one helped):

* created the actual base dir on the SG
* associated the SG CP Code with the property group id in Luna (strong candidate for this one)

## Save qa & prod

```
akamai pipeline --section a2s-open save -p demo.a2s.ninja qa
akamai pipeline --section a2s-open save -p demo.a2s.ninja prod
```

## Promote all envs

Once we've managed to save all envs, we need to promote them all. Because this is a demo, and because it's a prep step, we can brute force it.

```
for n in staging production; do
    for env in qa prod; do
        until akamai pipeline promote -p demo.a2s.ninja -n $n -e ahogg@akamai.com -m "zzz" $env; do
            sleep 10;
        done;
    done;
done
```

Done. The pipeline is ready for CI.


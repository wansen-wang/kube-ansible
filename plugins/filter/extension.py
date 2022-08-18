import re
import IPy
from ansible import errors
import operator as py_operator
from distutils.version import LooseVersion, StrictVersion
from ansible.module_utils._text import to_native, to_text
from ansible.utils.version import SemanticVersion


# {{ value | component_version | community.general.json_query("etcd") }}
# pip3 install jmespath
def component_version(value):
    version_map = {
        "1.14": {
            "etcd": "3.3.10",
            "cni": "0.7.5",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.14.12",
                "runc": "1.0.1",
                "crictl": "1.12.0"
            },
            "plugin": {
                "calico": "3.12.3",
                "flannel": "0.10.0",
                "coredns": "1.3.1",
                "metrics": "0.5.2"
            }
        },
        "1.15": {
            "etcd": "3.3.10",
            "cni": "0.7.5",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.15.4",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.15.5",
                "flannel": "0.10.0",
                "coredns": "1.6.7",
                "metrics": "0.5.2"
            }
        },
        "1.16": {
            "etcd": "3.3.15",
            "cni": "0.7.5",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.16.6",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.16.10",
                "cilium": "1.5.5",
                "flannel": "0.11.0",
                "coredns": "1.6.2",
                "metrics": "0.5.2"
            }
        },
        "1.17": {
            "etcd": "3.4.3",
            "cni": "0.8.6",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.17.5",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.17.6",
                "cilium": "1.7.2",
                "flannel": "0.12.0",
                "coredns": "1.6.5",
                "metrics": "0.5.2"
            }
        },
        "1.18": {
            "etcd": "3.4.3",
            "cni": "0.8.6",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.18.6",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.18.6",
                "cilium": "1.8.3",
                "flannel": "0.12.0",
                "coredns": "1.6.7",
                "metrics": "0.5.2"
            }
        },
        "1.19": {
            "etcd": "3.4.9",
            "cni": "0.9.0",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.11",
                "crio": "1.19.6",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.20.5",
                "cilium": "1.8.8",
                "flannel": "0.13.0",
                "coredns": "1.7.0",
                "metrics": "0.6.1"
            }
        },
        "1.20": {
            "etcd": "3.4.13",
            "cni": "0.9.0",
            "runtime": {
                "docker": "19.03.9",
                "containerd": "1.5.0",
                "crio": "1.20.9",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.21.5",
                "cilium": "1.8.8",
                "flannel": "0.13.0",
                "coredns": "1.7.0",
                "metrics": "0.6.1"
            }
        },
        "1.21": {
            "etcd": "3.4.13",
            "cni": "0.9.1",
            "runtime": {
                "docker": "20.10.9",
                "containerd": "1.5.0",
                "crio": "1.21.7",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.23.2",
                "cilium": "1.8.8",
                "flannel": "0.14.0",
                "coredns": "1.8.0",
                "metrics": "0.6.1"
            }
        },
        "1.22": {
            "etcd": "3.5.0",
            "cni": "1.0.1",
            "runtime": {
                "docker": "20.10.9",
                "containerd": "1.5.13",
                "crio": "1.22.5",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.23.2",
                "cilium": "1.9.11",
                "flannel": "0.15.1",
                "coredns": "1.8.4",
                "metrics": "0.6.1"
            }
        },
        "1.23": {
            "etcd": "3.5.0",
            "cni": "1.1.1",
            "runtime": {
                "docker": "20.10.9",
                "containerd": "1.6.0",
                "crio": "1.23.3",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.23.2",
                "cilium": "1.11.3",
                "flannel": "0.15.1",
                "coredns": "1.8.6",
                "metrics": "0.6.1"
            }
        },
        "1.24": {
            "etcd": "3.5.3",
            "cni": "1.1.1",
            "runtime": {
                "crio": "1.24.2",
                "containerd": "1.6.8",
                "runc": "1.0.1",
                "crictl": "1.24.2"
            },
            "plugin": {
                "calico": "3.23.2",
                "cilium": "1.11.3",
                "flannel": "0.15.1",
                "coredns": "1.8.6",
                "metrics": "0.6.1"
            }
        }
    }

    if version_map.get(value) is not None:
        return version_map.get(value)
    if version_map.get(value[:4]) is None:
        raise errors.AnsibleFilterError('kubernetes version not supported')
    return version_map.get(value[:4])


# {{ value | ip }}
# return 4 or 6
def ip(value):
    try:
        return IPy.IP(value).version()
    except Exception as e:
        raise errors.AnsibleFilterError(
            'ip failed: %s' % to_native(e))


# {{ value | ip_format }}
# if value is ipv4, will return ipv4. if value is ipv6 will return [value]
def ip_format(value):
    try:
        version = IPy.IP(value).version()
        if version == 4:
            return value
        else:
            return "[%s]" % value
    except Exception as e:
        raise errors.AnsibleFilterError(
            'ip failed: %s' % to_native(e))


def interception(value, x, y):
    return value[x:len(value) - y]


# {{ value | select('eq', '4', true, false) }}
# Ternary expression
def select(value, operator='eq', expectations=None, tValue=None, fValue=None):
    if not value:
        raise errors.AnsibleFilterError("Input value cannot be empty")
    if not expectations:
        raise errors.AnsibleFilterError("Input expectations cannot be empty")

    op_map = {
        '==': 'eq', '=': 'eq', 'eq': 'eq',
        '<': 'lt', 'lt': 'lt',
        '<=': 'le', 'le': 'le',
        '>': 'gt', 'gt': 'gt',
        '>=': 'ge', 'ge': 'ge',
        '!=': 'ne', '<>': 'ne', 'ne': 'ne'
    }
    if operator in op_map:
        operator = op_map[operator]
    else:
        raise errors.AnsibleFilterError(
            'Invalid operator type (%s). Must be one of %s' % (
                operator, ', '.join(map(repr, op_map)))
        )

    try:
        method = getattr(py_operator, operator)
        if method(to_text(value), to_text(expectations)):
            return tValue
        else:
            return fValue
    except Exception as e:
        raise errors.AnsibleFilterError(
            'Version comparison failed: %s' % to_native(e))


def split_string(string, separator=' '):
    try:
        return string.split(separator)
    except Exception as e:
        raise errors.AnsibleFilterError(
            'split plugin error: %s, provided string: "%s"' % str(e), str(string))


def split_regex(string, separator_pattern='\s+'):
    try:
        return re.split(separator_pattern, string)
    except Exception as e:
        raise errors.AnsibleFilterError(
            'split plugin error: %s, provided string: "%s"' % str(e), str(string))


def version_compare(value, version, operator='eq', strict=None, version_type=None):
    ''' Perform a version comparison on a value '''
    op_map = {
        '==': 'eq', '=': 'eq', 'eq': 'eq',
        '<': 'lt', 'lt': 'lt',
        '<=': 'le', 'le': 'le',
        '>': 'gt', 'gt': 'gt',
        '>=': 'ge', 'ge': 'ge',
        '!=': 'ne', '<>': 'ne', 'ne': 'ne'
    }

    type_map = {
        'loose': LooseVersion,
        'strict': StrictVersion,
        'semver': SemanticVersion,
        'semantic': SemanticVersion,
    }

    if strict is not None and version_type is not None:
        raise errors.AnsibleFilterError(
            "Cannot specify both 'strict' and 'version_type'")

    if not value:
        raise errors.AnsibleFilterError("Input version value cannot be empty")

    if not version:
        raise errors.AnsibleFilterError(
            "Version parameter to compare against cannot be empty")

    Version = LooseVersion
    if strict:
        Version = StrictVersion
    elif version_type:
        try:
            Version = type_map[version_type]
        except KeyError:
            raise errors.AnsibleFilterError(
                "Invalid version type (%s). Must be one of %s" % (
                    version_type, ', '.join(map(repr, type_map)))
            )

    if operator in op_map:
        operator = op_map[operator]
    else:
        raise errors.AnsibleFilterError(
            'Invalid operator type (%s). Must be one of %s' % (
                operator, ', '.join(map(repr, op_map)))
        )

    try:
        method = getattr(py_operator, operator)
        return method(Version(to_text(value)), Version(to_text(version)))
    except Exception as e:
        raise errors.AnsibleFilterError(
            'Version comparison failed: %s' % to_native(e))


class FilterModule(object):
    def filters(self):
        return {
            'select': select,
            'split': split_string,
            'split_regex': split_regex,
            'version_compare': version_compare,
            'version': version_compare,
            'interception': interception,
            'ip_format': ip_format,
            'ip': ip,
            'component_version': component_version
        }

# if __name__ == '__main__':
#     component_version("1.23.7")
#     print(select("4", "eq", "4", "10.96.0.0/12","fd74:ca9b:0172:0019::/110"))
#     a = "[fd74:ca9b:0172:0018::/64]"
#     print(a[1:len(a) - 1])
#     print()

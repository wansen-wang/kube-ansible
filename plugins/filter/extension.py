import re
import IPy
from ansible import errors
import operator as py_operator
from distutils.version import LooseVersion, StrictVersion
from ansible.module_utils._text import to_native, to_text
from ansible.utils.version import SemanticVersion


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
            'ip': ip
        }


# if __name__ == '__main__':
#     print(select("4", "eq", "4", "10.96.0.0/12","fd74:ca9b:0172:0019::/110"))
#     a = "[fd74:ca9b:0172:0018::/64]"
#     print(a[1:len(a) - 1])
#     print()

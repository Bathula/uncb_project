(function ($) {
    $.fn.extend({
        valid8: function (b) {
            return this.each(function () {
                $(this).data('valid', false);
                var a = {
                    regularExpressions: [],
                    ajaxRequests: [],
                    jsFunctions: [],
                    validationEvents: ['keyup', 'blur'],
                    validationFrequency: 1000,
                    values: null,
                    defaultErrorMessage: 'Required'
                };
                if (typeof b == 'string') a.defaultErrorMessage = b;
                if (this.type == 'checkbox') {
                    a.regularExpressions = [{
                        expression: /^true$/,
                        errormessage: a.defaultErrorMessage
                    }];
                    a.validationEvents = ['click']
                } else a.regularExpressions = [{
                    expression: /^.+$/,
                    errormessage: a.defaultErrorMessage
                }];
                $(this).data('settings', $.extend(a, b));
                initialize(this)
            })
        },
        isValid: function () {
            var a = true;
            this.each(function () {
                validate(this);
                if ($(this).data('valid') == false) a = false
            });
            return a
        }
    });

    function initializeDataObject(a) {
        $(a).data('loadings', new Array());
        $(a).data('errors', new Array());
        $(a).data('valids', new Array());
        $(a).data('keypressTimer', null)
    }
    function initialize(a) {
        initializeDataObject(a);
        activate(a)
    };

    function activate(b) {
        var c = $(b).data('settings').validationEvents;
        if (typeof c == 'string') $(b)[c](function (e) {
            handleEvent(e, b)
        });
        else {
            $.each(c, function (i, a) {
                $(b)[a](function (e) {
                    handleEvent(e, b)
                })
            })
        }
    };

    function validate(a) {
        initializeDataObject(a);
        var b;
        if (a.type == 'checkbox') b = a.checked.toString();
        else b = a.value;
        regexpValidation(b.replace(/^[ \t]+|[ \t]+$/, ''), a)
    };

    function regexpValidation(b, c) {
        $.each($(c).data('settings').regularExpressions, function (i, a) {
            if (!a.expression.test(b)) $(c).data('errors')[$(c).data('errors').length] = a.errormessage;
            else if (a.validmessage) $(c).data('valids')[$(c).data('valids').length] = a.validmessage
        });
        if ($(c).data('errors').length > 0) onEvent(c, 'error', false);
        else if ($(c).data('settings').jsFunctions.length > 0) {
            functionValidation(b, c)
        } else if ($(c).data('settings').ajaxRequests.length > 0) {
            fileValidation(b, c)
        } else {
            onEvent(c, 'valid', true)
        }
    };

    function functionValidation(c, d) {
        $.each($(d).data('settings').jsFunctions, function (i, a) {
            var v;
            if (a.values) {
                if (typeof a.values == 'function') v = a.values()
            }
            var b = v || c;
            handleLoading(d, a);
            if (a['function'](b).valid) $(d).data('valids')[$(d).data('valids').length] = a['function'](b).message;
            else $(d).data('errors')[$(d).data('errors').length] = a['function'](b).message
        });
        if ($(d).data('errors').length > 0) onEvent(d, 'error', false);
        else if ($(d).data('settings').ajaxRequests.length > 0) {
            fileValidation(c, d)
        } else {
            onEvent(d, 'valid', true)
        }
    };

    function fileValidation(e, f) {
        $.each($(f).data('settings').ajaxRequests, function (i, c) {
            var v;
            if (c.values) {
                if (typeof c.values == 'function') v = c.values()
            }
            var d = v || {
                value: e
            };
            handleLoading(f, c);
            $.post(c.url, d, function (a, b) {
                if (a.valid) {
                    $(f).data('valids')[$(f).data('valids').length] = a.message || c.validmessage || ""
                } else {
                    $(f).data('errors')[$(f).data('errors').length] = a.message || c.errormessage || ""
                }
                if ($(f).data('errors').length > 0) onEvent(f, 'error', false);
                else {
                    onEvent(f, 'valid', true)
                }
            }, "json")
        })
    };

    function handleEvent(e, a) {
        if (e.keyCode && $(a).attr('value').length > 0) {
            clearTimeout($(a).data('keypressTimer'));
            $(a).data('keypressTimer', setTimeout(function () {
                validate(a)
            }, $(a).data('settings').validationFrequency))
        } else if (e.keyCode && $(a).attr('value').length <= 0) return false;
        else {
            validate(a)
        }
    };

    function handleLoading(a, b) {
        if (b.loadingmessage) {
            $(a).data('loadings')[$(a).data('loadings').length] = b.loadingmessage;
            onEvent(a, 'loading', false)
        }
    };

    function onEvent(a, b, c) {
        var d = b.substring(0, 1).toUpperCase() + b.substring(1, b.length),
            messages = $(a).data(b + 's');
        $(a).data(b, c);
        setStatus(a, b);
        setParentClass(a, b);
        setMessage(messages, a);
        $(a).trigger(b, [messages, a, b])
    }
    function setParentClass(a, b) {
        var c = $(a).parent();
        c[0].className = (c[0].className.replace(/(^\s|(\s*(loading|error|valid)))/g, '') + ' ' + b).replace(/^\s/, '')
    }
    function setMessage(a, b) {
        var c = $(b).parent();
        var d = b.id + "ValidationMessage";
        var e = 'validationMessage';
        if (!$('#' + d).length > 0) {
            c.append('<span id="' + d + '" class="' + e + '"></span>');
        }
	 
        $('#' + d).html("");
        $('#' + d).text(a[0]);
	$('#' + d).show();
$("span.validationMessage:empty").hide();
	 
    };

    function setStatus(a, b) {
        if (b == 'valid') {
            $(a).data('valid', true)
        } else if (b == 'error') {
            $(a).data('valid', false)
        }
    }
})(jQuery);
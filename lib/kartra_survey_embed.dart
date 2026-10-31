import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

const _surveyScriptSrc =
    'https://app.kartra.com/js/build/front/embed/survey.js';

// survey.js tworzy jedną globalną instancję i skanuje DOM tylko przy pierwszym
// załadowaniu, więc każdą ankietę renderujemy ręcznie przez initInlineEmbed.
void mountKartraSurvey({
  required String wrapperId,
  required String surveyId,
  required String owner,
  required String accent,
}) {
  html.document.getElementById(wrapperId)?.remove();

  final wrapper = html.DivElement()
    ..id = wrapperId
    ..style.cssText =
        'position:fixed;top:56px;left:0;right:0;bottom:0;'
        'overflow-y:auto;z-index:9999;background:white;display:none;';

  final container = html.DivElement()
    ..setAttribute('data-kt-type', 'survey')
    ..setAttribute('data-kt-embed', 'inline')
    ..setAttribute('data-kt-value', surveyId)
    ..setAttribute('data-kt-owner', owner)
    ..setAttribute('data-kt-accent', accent);

  wrapper.append(container);
  html.document.body!.append(wrapper);

  // Przechwytuj wheel events zanim Flutter je zablokuje (capture phase)
  wrapper.addEventListener(
    'wheel',
    (event) => event.stopImmediatePropagation(),
    true,
  );

  if (html.document.querySelector('script[src="$_surveyScriptSrc"]') == null) {
    html.document.body!.append(
      html.ScriptElement()
        ..type = 'text/javascript'
        ..src = _surveyScriptSrc,
    );
  }

  _whenSurveyReady((api) {
    if (wrapper.parent == null) return;
    api.callMethod<JSAny?>('initInlineEmbed'.toJS, container as JSAny);
  });
}

void showKartraSurvey(String wrapperId) {
  html.document.getElementById(wrapperId)?.style.display = '';
}

void hideKartraSurvey(String wrapperId) {
  html.document.getElementById(wrapperId)?.style.display = 'none';
  html.document.body?.style.removeProperty('overflow');
}

JSObject? _surveyApi() {
  final kartra = globalContext.getProperty<JSObject?>('kartra'.toJS);
  final embeds = kartra?.getProperty<JSObject?>('embeds'.toJS);
  return embeds?.getProperty<JSObject?>('survey'.toJS);
}

void _whenSurveyReady(void Function(JSObject api) onReady, {int attempt = 0}) {
  final api = _surveyApi();
  if (api != null) {
    onReady(api);
    return;
  }
  if (attempt > 100) return; // max 10 sekund
  Future.delayed(
    const Duration(milliseconds: 100),
    () => _whenSurveyReady(onReady, attempt: attempt + 1),
  );
}

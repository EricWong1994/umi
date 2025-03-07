{{{ polyfillImports }}}
{{{ importsAhead }}}
import { renderClient } from '{{{ rendererPath }}}';
import { getRoutes } from './core/route';
import { createPluginManager } from './core/plugin';
import { createHistory } from './core/history';
{{#loadingComponent}}
import Loading from '@/loading';
{{/loadingComponent}}
import { ApplyPluginsType } from 'umi';
{{{ imports }}}

const publicPath = "{{{ publicPath }}}";
const runtimePublicPath = {{{ runtimePublicPath }}};

async function render() {
  const pluginManager = createPluginManager();
  const { routes, routeComponents } = await getRoutes(pluginManager);

  // allow user to extend routes
  await pluginManager.applyPlugins({
    key: 'patchRoutes',
    type: ApplyPluginsType.event,
    args: {
      routes,
      routeComponents,
    },
  });

  return (pluginManager.applyPlugins({
    key: 'render',
    type: ApplyPluginsType.compose,
    initialValue() {
      const contextOpts = pluginManager.applyPlugins({
        key: 'modifyContextOpts',
        type: ApplyPluginsType.modify,
        initialValue: {},
      });
      const basename = contextOpts.basename || '{{{ basename }}}';
      const context = {
{{#hydrate}}
        hydrate: true,
{{/hydrate}}
{{#reactRouter5Compat}}
        reactRouter5Compat: true,
{{/reactRouter5Compat}}
        routes,
        routeComponents,
        pluginManager,
        rootElement: contextOpts.rootElement || document.getElementById('{{{ mountElementId }}}'),
{{#loadingComponent}}
        loadingComponent: Loading,
{{/loadingComponent}}
        publicPath,
        runtimePublicPath,
        history: createHistory({
          type: contextOpts.historyType || '{{{ historyType }}}',
          basename,
          ...contextOpts.historyOpts,
        }),
        basename,
        callback: contextOpts.callback,
      };
      const modifiedContext = pluginManager.applyPlugins({
        key: 'modifyClientRenderOpts',
        type: ApplyPluginsType.modify,
        initialValue: context,
      });
      return renderClient(modifiedContext);
    },
  }))();
}

{{{ entryCodeAhead }}}
render();
{{{ entryCode }}}

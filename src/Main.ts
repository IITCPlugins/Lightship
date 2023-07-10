import * as Plugin from "iitcpluginkit";
import { lightshipDBProd, lightshipDBRest } from "./Database";

// FIXME in iitcpluginkit
declare global {
    interface Hightligher {
        hightlight: (data: { portal: IITC.Portal }) => void;
        setSelected?: (activate: boolean) => void;
    }
    function addPortalHighlighter(name: string, data: Hightligher): void;
}


class Lightship implements Plugin.Class {

    private prod: Set<string>;
    private rest: Set<string>;

    init(): void {
        window.addPortalHighlighter("Overclock", (this as unknown as Hightligher));
    }

    setSelected(activate: boolean): void {
        if (activate) {
            if (!this.prod) {
                this.prod = new Set(lightshipDBProd);
                this.rest = new Set(lightshipDBRest);

            }
        }
    }

    highlight(data: { portal: IITC.Portal }): void {
        const d = data.portal.options.data;

        const id = d.latE6.toString(36) + d.lngE6.toString(36);

        if (this.prod.has(id)) {
            data.portal.setStyle({ fillColor: "yellow" });
        } else {
            if (this.rest.has(id)) {
                data.portal.setStyle({ fillColor: "orange" });
            }
        }
    }
}


/**
 * use "main" to access you main class from everywhere
 * (same as window.plugin.Lightship)
 */
export const main = new Lightship();
Plugin.Register(main, "Lightship");

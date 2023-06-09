import * as Plugin from "iitcpluginkit";
import { lightshipDB } from "./Database";

// FIXME in iitcpluginkit
declare global {
    interface Hightligher {
        hightlight: (data: { portal: IITC.Portal }) => void;
        setSelected?: (activate: boolean) => void;
    }
    function addPortalHighlighter(name: string, data: Hightligher): void;
}


class Lightship implements Plugin.Class {

    init(): void {
        window.addPortalHighlighter("Lightship", (this as unknown as Hightligher));
    }

    setSelected(activate: boolean): void {
        if (activate) {
            // TODO: init DB here
        }
    }

    highlight(data: { portal: IITC.Portal }): void {
        const d = data.portal.options.data;

        const id = d.latE6.toString(36) + "_" + d.lngE6.toString(36)

        if (lightshipDB.has(id)) {
            data.portal.setStyle({ fillColor: "yellow" });
        }
    }
}

/**
 * use "main" to access you main class from everywhere
 * (same as window.plugin.Lightship)
 */
export const main = new Lightship();
Plugin.Register(main, "Lightship");

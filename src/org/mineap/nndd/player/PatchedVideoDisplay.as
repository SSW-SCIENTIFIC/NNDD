package org.mineap.nndd.player {
    import mx.core.mx_internal;

    import org.osmf.media.videoClasses.VideoSurface;

    import spark.components.VideoDisplay;

    use namespace mx_internal;

    public class PatchedVideoDisplay extends VideoDisplay {
        public function get videoSurfaceObject(): VideoSurface {
            return this.videoPlayer.displayObject as VideoSurface;
        }
    }
}



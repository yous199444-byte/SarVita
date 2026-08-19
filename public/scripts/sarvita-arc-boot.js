(function () {
    "use strict";

    const BOOT_ID = "sarvita-arc-boot";

    function createBootScreen() {

        if (document.getElementById(BOOT_ID)) {
            return;
        }

        const boot = document.createElement("div");

        boot.id = BOOT_ID;

        boot.innerHTML = `
            <div id="sarvita-arc-boot-content">

                <img
                    id="sarvita-arc-boot-image"
                    src="/img/branding/sarvita-arc/main/sarvita-arc-main-square.png"
                    alt="SarVita Arc"
                >

                <div id="sarvita-arc-boot-brand">
                    SarVita Arc
                </div>

                <div id="sarvita-arc-boot-status">
                    Initializing...
                </div>

            </div>
        `;

        document.body.appendChild(boot);
    }

    function hideBootScreen() {

        const boot =
            document.getElementById(BOOT_ID);

        if (!boot) {
            return;
        }

        boot.style.transition =
            "opacity .45s ease";

        boot.style.opacity = "0";

        setTimeout(function () {

            if (boot && boot.parentNode) {
                boot.parentNode.removeChild(boot);
            }

        }, 500);
    }

    if (document.readyState === "loading") {

        document.addEventListener(
            "DOMContentLoaded",
            createBootScreen
        );

    } else {

        createBootScreen();
    }

    window.addEventListener(
        "load",
        function () {

            setTimeout(
                hideBootScreen,
                700
            );

        },
        { once: true }
    );

    setTimeout(
        hideBootScreen,
        10000
    );

})();

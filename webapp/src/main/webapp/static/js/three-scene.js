/* ============================================================
   AgentHire AI — 3D Scroll-Reactive Scene
   A glowing wireframe icosahedron that rotates based on scroll
   ============================================================ */

(function () {
    'use strict';

    // Only run on landing page
    var container = document.getElementById('three-canvas');
    if (!container) return;

    // Lazy-load Three.js from CDN
    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js';
    script.onload = initScene;
    document.head.appendChild(script);

    function initScene() {
        var scene = new THREE.Scene();

        var camera = new THREE.PerspectiveCamera(
            55,
            container.clientWidth / container.clientHeight,
            0.1,
            1000
        );
        camera.position.z = 5;

        var renderer = new THREE.WebGLRenderer({
            canvas: container,
            alpha: true,
            antialias: true,
        });
        renderer.setSize(container.clientWidth, container.clientHeight);
        renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
        renderer.setClearColor(0x000000, 0);

        // --- Main Icosahedron (wireframe) ---
        var icoGeo = new THREE.IcosahedronGeometry(2.0, 1);
        var icoMat = new THREE.MeshBasicMaterial({
            color: 0x7c3aed,
            wireframe: true,
            transparent: true,
            opacity: 0.18,
        });
        var ico = new THREE.Mesh(icoGeo, icoMat);
        scene.add(ico);

        // --- Inner solid icosahedron (subtle fill) ---
        var innerGeo = new THREE.IcosahedronGeometry(1.85, 1);
        var innerMat = new THREE.MeshBasicMaterial({
            color: 0x4f46e5,
            transparent: true,
            opacity: 0.04,
        });
        var innerIco = new THREE.Mesh(innerGeo, innerMat);
        scene.add(innerIco);

        // --- Outer ring (decorative torus) ---
        var torusGeo = new THREE.TorusGeometry(2.8, 0.012, 16, 100);
        var torusMat = new THREE.MeshBasicMaterial({
            color: 0x06b6d4,
            transparent: true,
            opacity: 0.12,
        });
        var torus = new THREE.Mesh(torusGeo, torusMat);
        torus.rotation.x = Math.PI / 3;
        scene.add(torus);

        // --- Particle dots around the object ---
        var particleCount = 120;
        var positions = new Float32Array(particleCount * 3);
        for (var i = 0; i < particleCount; i++) {
            var theta = Math.random() * Math.PI * 2;
            var phi = Math.acos(2 * Math.random() - 1);
            var r = 3.2 + Math.random() * 1.5;
            positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
            positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
            positions[i * 3 + 2] = r * Math.cos(phi);
        }
        var particleGeo = new THREE.BufferGeometry();
        particleGeo.setAttribute(
            'position',
            new THREE.BufferAttribute(positions, 3)
        );
        var particleMat = new THREE.PointsMaterial({
            color: 0xa78bfa,
            size: 0.025,
            transparent: true,
            opacity: 0.5,
        });
        var particles = new THREE.Points(particleGeo, particleMat);
        scene.add(particles);

        // --- Scroll tracking ---
        var scrollY = 0;
        var targetScrollY = 0;
        window.addEventListener(
            'scroll',
            function () {
                targetScrollY = window.pageYOffset || document.documentElement.scrollTop;
            },
            { passive: true }
        );

        // --- Mouse parallax ---
        var mouseX = 0;
        var mouseY = 0;
        document.addEventListener(
            'mousemove',
            function (e) {
                mouseX = (e.clientX / window.innerWidth - 0.5) * 2;
                mouseY = (e.clientY / window.innerHeight - 0.5) * 2;
            },
            { passive: true }
        );

        // --- Resize handler ---
        function onResize() {
            var w = container.clientWidth;
            var h = container.clientHeight;
            camera.aspect = w / h;
            camera.updateProjectionMatrix();
            renderer.setSize(w, h);
        }
        window.addEventListener('resize', onResize);

        // --- Animation loop ---
        var clock = new THREE.Clock();
        function animate() {
            requestAnimationFrame(animate);
            var t = clock.getElapsedTime();

            // Smooth scroll interpolation
            scrollY += (targetScrollY - scrollY) * 0.08;
            var scrollFactor = scrollY * 0.001;

            // Main icosahedron: auto-rotate + scroll-driven rotation
            ico.rotation.x = t * 0.08 + scrollFactor * 1.2;
            ico.rotation.y = t * 0.12 + scrollFactor * 0.8;
            ico.rotation.z = t * 0.05;

            // Mouse parallax on the icosahedron
            ico.position.x = mouseX * 0.15;
            ico.position.y = -mouseY * 0.15;

            // Inner ico follows
            innerIco.rotation.x = ico.rotation.x;
            innerIco.rotation.y = ico.rotation.y;
            innerIco.rotation.z = ico.rotation.z;
            innerIco.position.x = ico.position.x;
            innerIco.position.y = ico.position.y;

            // Torus: counter-rotate gently
            torus.rotation.x = Math.PI / 3 + t * 0.04;
            torus.rotation.z = t * 0.06 + scrollFactor * 0.5;
            torus.position.x = ico.position.x;
            torus.position.y = ico.position.y;

            // Particles: slow rotation
            particles.rotation.y = t * 0.02 + scrollFactor * 0.3;
            particles.rotation.x = t * 0.015;

            // Fade opacity based on scroll (fade out as user scrolls down)
            var fadeOut = Math.max(0, 1 - scrollY / 900);
            icoMat.opacity = 0.18 * fadeOut;
            innerMat.opacity = 0.04 * fadeOut;
            torusMat.opacity = 0.12 * fadeOut;
            particleMat.opacity = 0.5 * fadeOut;

            renderer.render(scene, camera);
        }
        animate();
    }
})();

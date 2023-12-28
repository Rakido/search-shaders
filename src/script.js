import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import vertex from './shaders/test/vertex.glsl'
import fragment from './shaders/test/fragment.glsl'

/**
 * DEBUG
 */
const gui = new dat.GUI()

/**
 *  BASE
 */
// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Axis Helper
// const axesHelper = new THREE.AxesHelper(5);
// scene.add(axesHelper);

/**
 * Objects
 */

// Textures
//const textureLoader = new THREE.TextureLoader()
//const flagTexture = textureLoader.load('/textures/test-9.png')

// Geometry
const geometry = new THREE.PlaneGeometry(10,10)

// Colors
const green = new THREE.Color("rgb(68, 207, 108)")
const blue = new THREE.Color("rgb(55, 70, 190)")

// Uniform for mouse position
const mouse = new THREE.Vector2();

window.addEventListener('mousemove', (event) => {
    mouse.x = (event.clientX / sizes.width) * 2 - 1;
    mouse.y = -(event.clientY / sizes.height) * 2 + 1;

    // Update the mouse uniform in shader
    material.uniforms.u_mouse.value.x = 1 - (event.clientX / sizes.width);
    material.uniforms.u_mouse.value.y = 1 - (event.clientY / sizes.height);
});


// Material
const material = new THREE.ShaderMaterial({
    side:  THREE.DoubleSide,
    // Uniforms for the shader
    uniforms: {
        u_resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
        iTime: { value: 0 },
        iResolution: { value: new THREE.Vector3() },
        u_color1: { value: green },
        u_color2: { value: blue },
        u_mouse: { value: mouse }
    },
    vertexShader: vertex,
    fragmentShader: fragment
})

//gui.add(material.uniforms.uFrequency.value, 'x').min(0).max(20).step(0.01).name('frequencyX')
//gui.add(material.uniforms.uFrequency.value, 'y').min(0).max(20).step(0.01).name('frequencyY')


// Mesh
const mesh = new THREE.Mesh(geometry, material)
scene.add(mesh)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */

// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(1, 1, -2)
//gui.add(material.uniforms.uFrequency.value, 'x').min(0).max(20).step(0.01).name('frequencyX')
//gui.add(mesh.position.y, 'x').min(-20).max(100).step(1).name("x")
scene.add(camera)

// Orthographic Camera
// const frutumSize = 2;
// const aspect = sizes.width / sizes.height;
// const camera = new THREE.OrthographicCamera( frutumSize * aspect / - 2, frutumSize * aspect / 2, frutumSize / 2, frutumSize / - 2, -1000, 1000 );
// camera.position.set(0, 0, -2)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Lights
 */

const light1 = new THREE.AmbientLight(0xFFFFFF, 0.9)
scene.add(light1)

const light2 = new THREE.DirectionalLight(0xFFFFFF, 0.5)
light2.position.set(0, -1, 0)
scene.add(light2)


/**
 * Animate
 */
const clock = new THREE.Clock()
console.log(material.uniforms)
const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()
    // Update controls
    controls.update()

    material.uniforms.iTime.value = elapsedTime * 0.5 ;
    //material.uniforms.u_mouse.value = mouse;

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()
import wollok.game.*
import naves.*
import pantallas.*
import extras.*
import enemigo.*

//Fondo para pantallas y escenarios
class Fondo{
	const property position = game.origin()
	var property image
	method esEnemigo()=false
	method tieneVida()=false
	method interaccionCon(jugador){}
	method sonido(sonidoDeFondo)
	{
		sonidoDeFondo.shouldLoop(true)
		sonidoDeFondo.volume(0.5)
		game.schedule(150, {sonidoDeFondo.play()})
	}
}

//Marcos para as selecciones en las pantallas de selección
class Marco{
	var property position
	var property image
	var movimiento = true
	var x1
	var x2
	
	method movimiento() = movimiento
	
	method liberarMovimiento()
	{
		movimiento = true
	}
	
	method bloquearMovimiento(){
		movimiento = false
	}
	
	//Movimiento marcos de selección
	method irALosLados(nuevaPosicion){
		if (self.validarRango(nuevaPosicion)){
			position = nuevaPosicion
		}
	}
	
	method validarRango(nuevaPosicion){
		return nuevaPosicion.x().between(x1,x2)
	}
	
}

//Escenarios de selección
class Escenario{
	var property position
	var property image=""
	var property sonidoDeFondo
	
}

//Portada de inicio de juego
object portada{

	const property testeo = new Fondo(image="assets/portada.png")
	var property intro = game.sound("assets/intro.mp3")

	method iniciar(){
		game.addVisual(testeo)
		keyboard.enter().onPressDo{
			game.clear()
			instrucciones.iniciar()
			
		}
		game.schedule(150, {intro.play()})
		intro.shouldLoop(true)
		intro.volume(0.5)
		}	
	}

//Segunda pantalla controles
object instrucciones{
	method iniciar(){
		
		game.addVisual(new Fondo(image="assets/controles.png"))
		keyboard.enter().onPressDo{seleccionEscenarios.iniciar()}
	}
}

//Tercer pantalla selección de escenarios
object seleccionEscenarios{
	var property cualFondo
	const property marco3 = new Marco(position = game.at(2,3), image = "assets/marco3.png", x1 = 2, x2 = 16)
	method space()		  = new Escenario( position = game.at(2,3), image = "assets/spaceSmall.png", sonidoDeFondo = game.sound("assets/track1.mp3") )
	method clouds()	      = new Escenario( position = game.at(6,3), image = "assets/cloudsSmall.png", sonidoDeFondo = game.sound("assets/track2.mp3"))
	method pinkNebula()	  = new Escenario( position = game.at(10,3), image = "assets/pinknebulaSmall.png", sonidoDeFondo = game.sound("assets/track3.mp3"))
	method futuro() 	  = new Escenario( position = game.at(14,3), image = "assets/futureSmall.png", sonidoDeFondo = game.sound("assets/track4.mp3"))
	
	method iniciar(){
		game.clear()
		game.addVisual(new Fondo(image="assets/escenario.png"))
		self.agregarEscenarios()
		self.agregarTeclas()
	}
	
	//Agrega escenarios y marco de selección de escenarios
	method agregarEscenarios(){
		game.addVisual(self.space())
		game.addVisual(self.clouds())
		game.addVisual(self.pinkNebula())
		game.addVisual(self.futuro())
		game.addVisual(marco3)//y agregamos marco ya que estamos
	}
	
	//Teclas paa los marcos de selección
	method agregarTeclas(){
		keyboard.enter().onPressDo{if (marco3.movimiento()){
									marco3.bloquearMovimiento()
									cualFondo = game.uniqueCollider(marco3)
									seleccionNaves.iniciar()
									}}

		self.controlMovimiento()
		
	}
	
	//Los marcos se mueven de a 4 en x para posicionarse sobre los sobre los escenarios de selección
	method controlMovimiento(){
		keyboard.left().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().left(4))}}
		keyboard.right().onPressDo{if (marco3.movimiento()) {marco3.irALosLados(marco3.position().right(4))}}
	}
	
}

//Pantalla selección de naves
object seleccionNaves{
	var property n1 = new Nave1(position=game.at(7,4), jugador = "")
	var property n2 = new Nave2(position=game.at(9,4), jugador = "")
	var property n3 = new Nave3(position=game.at(11,4), jugador = "")
	
	const property naves=[n1,n2,n3]
	
	var property marco1 = new Marco(position = game.at(7,4), image = "assets/marco1.png", x1 = 7, x2 = 12)
	var property marco2 = new Marco(position = game.at(9,4), image = "assets/marco2.png", x1 = 7, x2 = 12)
	
	//Inicia equipo de armamento básico de nave
	method iniciarArmamento(coleccion){
		coleccion.forEach({nave=>nave.iniciarArmamento()})
	}
	
	method iniciar(){
		game.clear()
		self.iniciarArmamento(naves)
		game.addVisual(new Fondo(image="assets/instrucciones.png"))
		self.agregarNaves()
		self.agregarTeclas()
	}
	
	method agregarNaves(){
		game.addVisual(new Fondo(image="assets/seleccion.png"))
		game.addVisual(n1)
		game.addVisual(n2)
		game.addVisual(n3)
		game.addVisual(marco1)//y agregamos marcos ya que estamos
		game.addVisual(marco2)
	}

	method escogerNave(_marco,playerSelecc){
	//unificado selección de nave para jugadores 1 y 2.Pasa el marco posicionado sobre la nave y el jugador como parametro
			
		if (not self.superpuestos()) {
		 _marco.bloquearMovimiento()
		 playerSelecc.nave(game.uniqueCollider(_marco))
		 game.uniqueCollider(_marco).jugador(playerSelecc)
		 playerSelecc.naveSeleccionada(true)
		 }	 
	}
	
	//Controla que no elijan la misma nave
	method superpuestos()=marco1.position()==marco2.position()
	
	
	method agregarTeclas(){
		keyboard.enter().onPressDo{self.iniciar()}
		keyboard.a().onPressDo{if (marco1.movimiento()){marco1.irALosLados(marco1.position().left(2))}	}
		keyboard.d().onPressDo{if (marco1.movimiento()) {marco1.irALosLados(marco1.position().right(2))}}
		keyboard.e().onPressDo{if (marco1.movimiento()){self.escogerNave(marco1,jugador1)self.navesSeleccionadas()}}
						//IMPORTANTE method con parametros para elección de pjs
						//Modificado	
		keyboard.left().onPressDo{if (marco2.movimiento()) {marco2.irALosLados(marco2.position().left(2))}}
		keyboard.right().onPressDo{if (marco2.movimiento()) {marco2.irALosLados(marco2.position().right(2))}}
		keyboard.l().onPressDo{if (marco2.movimiento()){self.escogerNave(marco2,jugador2) self.navesSeleccionadas()}}
		}
	
	//Después de seleccionar una nave controla si los dos seleccionaron e inicia batalla, caso contrario no hace nada
	method navesSeleccionadas()=if(self.seleccionNavesOk()){
		portada.intro().stop()
		portada.intro(game.sound("assets/intro.mp3"))
		batalla.iniciar()
	}else{}
	
	//Controla si jugador 1 y 2 seleccionaron nave
	method seleccionNavesOk()= jugador1.naveSeleccionada() and jugador2.naveSeleccionada()
		
}


//Control de colisiones. Valida desde el inicio para los jugadores que inician y posteriormente los enemigos que se van agregando
object colisiones
{	
	var property jugadores = [jugador1,jugador2]
		
	method validar()= jugadores.forEach({jugador =>game.onCollideDo(jugador.nave(),{objeto =>objeto.interaccionCon(jugador)})})
		
	method validarEnemigo(enemigo)=game.onCollideDo(enemigo.nave(),{objeto => objeto.interaccionCon(enemigo)})	
}
	

object visualesGeneral
{	
	//Visualales batalla
	method agregar()
	{
		const visuales = [jugador1.nave(),jugador2.nave(),vida1,vida2,energia1,energia2,energia1Png,energia2Png]
		
		visuales.forEach{ visual=>
			game.addVisual(visual)
		}
		self.agregarOrbes()
	}
	
	//Los orbes se agregan cada cierto tiempo y se regeneran una vez que se pickean del lado del jugador que los tomó
	method agregarOrbes()
	{
		var time = 5000
		
		game.schedule(time,{new OrbeEnergia().agregarOrbeP1() new OrbeEnergia().agregarOrbeP2()})
		game.schedule(time*3,{
			new OrbeRafaga().agregarOrbeP1() 
			new OrbeRafaga().agregarOrbeP2() 
			new Enemigo().iniciarEnemigo(jugador1) 
			new Enemigo().iniciarEnemigo(jugador2)
		})
		game.schedule(time*5,{new OrbeMisil().agregarOrbeP1() new OrbeMisil().agregarOrbeP2()})
		game.schedule(time*8,{new OrbeVida().agregarOrbeP1() new OrbeVida().agregarOrbeP2()})
		game.schedule(time*10,{new OrbeDirigido().agregarOrbeP1() new OrbeDirigido().agregarOrbeP2()})			
	}
}

object batalla
{
	var escenarioElegido
	var fondoElegido
	method iniciar()
	{
		escenarioElegido=seleccionEscenarios.cualFondo()
		//Calcula imagen de esenario con valores de los escenarios de selección
		fondoElegido = new Fondo(image=escenarioElegido.image().toString().replace("Small", ""))
		self.colocarNaves()
		game.clear()
		game.addVisual(fondoElegido)
		fondoElegido.sonido(escenarioElegido.sonidoDeFondo())
		
		
		visualesGeneral.agregar()
		jugador1.controles()
		jugador2.controles()
		colisiones.validar()
		final.escenario(escenarioElegido)
		
	}
	
	//Inicia posición y dirección de las naves para el jugador
	method colocarNaves(){
		jugador1.colocarNave()
		jugador2.colocarNave()		
	}
}
object final
{		//Pantalla final batalla
	var final
	var property escenario
	
	var property victory = game.sound("assets/victoria.mp3")
	
	method finalizarBatalla(escenarioFin){
		
		game.clear()
		game.addVisual(final)
		escenarioFin.sonidoDeFondo().stop()
		self.sound()
		self.iniciar()


	}
	
	//Lanza sonido de victoria
	method sound(){
		victory.play()
		victory.shouldLoop(false)
		victory.volume(0.5)
	}
	
	//Limpia lista de control de colisiones y la reinicia 
	method limpiarLista(jugadores){
		jugadores.clear()
		jugadores.add(jugador1)
		jugadores.add(jugador2)
	}
	
	// IMPORTANTE unificar validar vida, tiene que ser uno solo y el jugador/imagen sea por parametro
	//Unificado
	//Quita jugador muerto de la lista y calcula numero del jugador ganador
	method remover(jugadores) {			
			jugadores.remove(self.elMuerto(jugadores))
			final = new Fondo(image="assets/final"+self.win(jugadores))
			self.limpiarLista(jugadores)			
			self.finalizarBatalla(escenario)
	}
	
	method elMuerto(jugadores)=jugadores.find({jugador=>jugador.vidas()<=0})//seleccional al muerto
		
	//method muertos(jugadores)=not jugadores.filter({jugador=>jugador.vidas()<=0}).isEmpty()//Controla muertos, usa colecciones
	
	method win(jugadores)=jugadores.find({jugador=>jugador.vidas()>0}).toString().drop(7)+".png"//Asigna número jugador ganador quita primeras 7 letras "jugador"

	method iniciar(){
		self.reiniciar()
		keyboard.enter().onPressDo{
			game.clear()
			victory.stop()
			//Wollok pide liberar el recurso de sonido y reinicializarlo para que pueda volver a lanarse luego de hacer stop
			victory=game.sound("assets/victoria.mp3")
			portada.intro().play()
			//Reinicia pantalla de controles
			instrucciones.iniciar()
			
		}

	}
	
	//Reinicializa todas las variable de nave y jugador
	method reiniciar(){
		seleccionNaves.n1(baseDeDatos.bp1())
		seleccionNaves.n2(baseDeDatos.bp2())
		seleccionNaves.n3(baseDeDatos.bp3())
		
		seleccionNaves.iniciarArmamento([seleccionNaves.n1(),seleccionNaves.n2(),seleccionNaves.n3()])

		seleccionNaves.marco1(baseDeDatos.bmarco1())
		seleccionNaves.marco2(baseDeDatos.bmarco2())
		
		seleccionEscenarios.marco3().liberarMovimiento()
		seleccionNaves.marco1().liberarMovimiento()
		seleccionNaves.marco2().liberarMovimiento()
		
		jugador1.naveSeleccionada(false)
		jugador2.naveSeleccionada(false)
		
		jugador1.vidas(baseDeDatos.bvida())
		jugador2.vidas(baseDeDatos.bvida())
		jugador1.energia(baseDeDatos.benergia())
		jugador2.energia(baseDeDatos.benergia())
	}
}
object  baseDeDatos{
		method bp1() = new Nave1(position=game.at(7,4),jugador=null)
		method bp2() = new Nave2(position=game.at(9,4),jugador=null)
		method bp3() = new Nave3(position=game.at(11,4),jugador=null)

		method bmarco1() = new Marco(position = game.at(7,4), image = "assets/marco1.png", x1 = 7, x2 = 12)
		method bmarco2() = new Marco(position = game.at(9,4), image = "assets/marco2.png", x1 = 7, x2 = 12)
		
		method bjugadorOk() = false
		
		method bvida() = 100
		method benergia()= 100
	}

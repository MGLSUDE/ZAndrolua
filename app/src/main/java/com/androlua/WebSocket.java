package com.androlua;
import org.java_websocket.client.WebSocketClient;
import java.net.URI;
import org.java_websocket.drafts.Draft;
import java.util.Map;
import org.java_websocket.handshake.ServerHandshake;
import java.net.URISyntaxException;

public class WebSocket extends WebSocketClient {

	private WebSocketListeners webSocketListeners;
	
	@Override
	public void onOpen(ServerHandshake handshakedata) {
		webSocketListeners.onOpen(handshakedata);
	}

	@Override
	public void onMessage(String message) {
		webSocketListeners.onMessage(message);
	}

	@Override
	public void onClose(int code, String reason, boolean remote) {
		webSocketListeners.onClose(code,reason,remote);
	}

	@Override
	public void onError(Exception ex) {
		webSocketListeners.onError(ex);
	}

   public WebSocket(String serverUri,WebSocketListeners websocketListeners) throws URISyntaxException {
		super(new URI(serverUri));
		this.webSocketListeners=websocketListeners;
	}
    
    public WebSocket(URI serverUri,WebSocketListeners websocketListeners) {
		super(serverUri);
		this.webSocketListeners=websocketListeners;
	}
	
	/**
	 * Constructs a WebSocketClient instance and sets it to the connect to the specified URI. The
	 * channel does not attampt to connect automatically. The connection will be established once you
	 * call <var>connect</var>.
	 *
	 * @param serverUri   the server URI to connect to
	 * @param httpHeaders Additional HTTP-Headers
	 * @since 1.3.8
	 */
	public WebSocket(URI serverUri, Map<String, String> httpHeaders,WebSocketListeners websocketListeners) {
		super(serverUri, httpHeaders);
		this.webSocketListeners=websocketListeners;
	}

	/**
	 * Constructs a WebSocketClient instance and sets it to the connect to the specified URI. The
	 * channel does not attampt to connect automatically. The connection will be established once you
	 * call <var>connect</var>.
	 *
	 * @param serverUri     the server URI to connect to
	 * @param protocolDraft The draft which should be used for this connection
	 * @param httpHeaders   Additional HTTP-Headers
	 * @since 1.3.8
	 */
	public WebSocket(URI serverUri, Draft protocolDraft, Map<String, String> httpHeaders,WebSocketListeners websocketListeners) {
		super(serverUri, protocolDraft, httpHeaders);
		this.webSocketListeners=websocketListeners;
	}

	
	public interface WebSocketListeners{
		public void onOpen(ServerHandshake handshakedata)
		public void onMessage(String message) 
		public void onClose(int code, String reason, boolean remote) 
		public void onError(Exception ex) 
	}
	
    
}

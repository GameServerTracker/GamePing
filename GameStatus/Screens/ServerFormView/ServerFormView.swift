//
//  ServerFormView.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI
import SwiftData

struct ServerFormView: View {

    let server: GameServer?

    @Environment(\.modelContext) private var context
    
    @StateObject var viewModel: ServerFormViewModel
    @FocusState private var focusedTextField: FormTextField?

    @Binding var isShowing: Bool

    init(server: GameServer?, isShowing: Binding<Bool>) {
        self.server = server
        self._isShowing = isShowing
        _viewModel = StateObject(wrappedValue: ServerFormViewModel(server: server))
    }
    
    enum FormTextField: Hashable {
        case hostname, name
    }
    
    var body: some View {
        NavigationView() {
            Form {
                Section(header: Text("Server Info")) {
                    TextField("Hostname - myserver.net", text: $viewModel.serverAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedTextField, equals: FormTextField.hostname)
                        .onSubmit {
                            if (viewModel.serverName.isEmpty) {
                                viewModel.serverName = viewModel.serverAddress
                            }
                            focusedTextField = .name
                        }
                        .submitLabel(.next)
                    TextField("Server Name - My Server", text: $viewModel.serverName)
                        .focused($focusedTextField, equals: FormTextField.name)
                        .onSubmit { focusedTextField = nil }
                        .submitLabel(.continue)
                    Picker("Type", selection: $viewModel.serverType) {
                        Text("Minecraft Java Edition").tag(GameServerType.minecraft)
                        Text("Minecraft Bedrock Edition").tag(GameServerType.minecraftBedrock)
                        Text("Source (CS,TF2,GMod,...)").tag(GameServerType.source)
                        Text("FiveM / RedM").tag(GameServerType.fivem)
                    }
                    TextField("Port", value: $viewModel.serverPort, format: .number)
                        .keyboardType(.numberPad)
                }
            }.navigationTitle(Text(server == nil ? "Add a server" : "Edit server"))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.save(context: context)
                            isShowing = false
                        } label: {
                            Text("Save")
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isShowing = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    ServerFormView(server: nil, isShowing: .constant(true))
        .modelContainer(for: GameServer.self, inMemory: true)
}

//
//  ServerFormView.swift
//  GameStatus
//
//  Created by Tom on 15/06/2025.
//

import SwiftUI

struct ServerFormView: View {
    
    @StateObject var viewModel: ServerFormViewModel = ServerFormViewModel()
    @FocusState private var focusedTextField: FormTextField?
    
    @Binding var isShowing: Bool
    
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
            }.navigationTitle(Text("Add a server"))
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            
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
    ServerFormView(isShowing: .constant(true))
}
